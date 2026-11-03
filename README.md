# TFBode for Scilab / Xcos

A small ATOMS toolbox that makes Bode plots easier to use from transfer functions and Xcos block diagrams.

Scilab already has [`bode()`](https://help.scilab.org/bode) and [`lincos()`](https://help.scilab.org/lincos). TFBode adds a coefficient-entry dialog, frequency bounds in Hz or rad/s, and two Xcos **Tools** menu commands.

## Install

Download the toolbox ZIP from this repository's releases, then run in Scilab:

```scilab
atomsInstall("/path/to/tfbode-0.3.0-scilab-2026.1.zip", "user");
atomsLoad("tfbode");
```

Or download/clone the source, change Scilab's working directory to its folder, and run:

```scilab
exec("install.sce", -1);
```

The source installer builds and loads the current session. ATOMS handles installed-package startup loading. This toolbox is not yet listed in the public ATOMS catalogue, so `atomsInstall("tfbode")` alone will not download it.

## Use

```scilab
tfbode(); // interactive coefficient entry

G = tfbode_system([10], [1 2 10]); // 10/(s^2 + 2s + 10)
tfbode(G, 0.01, 100, "rad/s");
```

Coefficients use descending powers; include zeros for missing terms. Existing `syslin` systems also work. Choose `"Hz"` for cycles per second.

In Xcos, open or reopen your diagram after loading the toolbox:

- **Tools → Bode plot of selected block** analyzes a selected continuous transfer block or superblock.
- **Tools → Bode plot of diagram** analyzes the connected system between one `IN_f` input and `OUT_f` output ports. In an analysis copy, replace the step source and scope with these ports and remove unused clocks.

Try `exec("demos/xcos_example.sce", -1)` for a ready-to-use diagram.

## Limits

Tested on **Scilab 2026.1.0 / Windows**. Rebuild the source for other versions; they are not verified. Xcos analysis is continuous-time, with a scalar input, and uses zero-state/zero-input linearization. For nonlinear systems, supply an operating point through `tfbode_xcos(scs_m, lo, hi, units, x0, u0)`. Clocked/discrete diagrams are unsupported; discrete `syslin` models work with `tfbode()` below Nyquist.

## Development

Run `tests/run.sce` and `tests/xcos.sce` in separate Scilab processes (both exit when finished). Run `package.ps1` after building, then `tests/package.sce` to check the archive. No C compiler or extra toolbox is required.

BSD-3-Clause. See [LICENSE](LICENSE). Review notes: [REVIEW.md](REVIEW.md).

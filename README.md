# TFBode for Scilab / Xcos

A small ATOMS toolbox that makes Bode plots easier to use from transfer functions and Xcos block diagrams.

Scilab already has [`bode()`](https://help.scilab.org/bode) and [`lincos()`](https://help.scilab.org/lincos). TFBode adds a coefficient-entry dialog, frequency bounds in Hz or rad/s, and two Xcos **Tools** menu commands.

## Install

This feature branch builds **0.4.0** with discrete Xcos support. The published
0.3.0 release does not include that feature. Use this branch's source installer
or its locally built ZIP:

```scilab
atomsInstall("/path/to/tfbode-0.4.0-scilab-2026.1.zip", "user");
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

D = tfbode_system([1], [1 -0.5], 0.1); // 1/(z-0.5), sample period 0.1 s
tfbode(D, 0.01, 4, "Hz"); // Nyquist is 5 Hz
```

Coefficients use descending powers; include zeros for missing terms. Existing `syslin` systems also work. Choose `"Hz"` for cycles per second.

In Xcos, open or reopen your diagram after loading the toolbox:

- **Tools → Bode plot of selected block** analyzes a selected transfer/state-space block, scalar delay, or superblock.
- **Tools → Bode plot of diagram** analyzes the connected system between one `IN_f` input and `OUT_f` output ports. In an analysis copy, replace the step source and scope with these ports and remove unused clocks.

Try `exec("demos/xcos_example.sce", -1)` for a ready-to-use diagram.

## Discrete Xcos systems

In either Tools menu dialog, enter a positive **sample period in seconds** for
discrete analysis; use `0` for continuous analysis. Leave maximum frequency blank
to use 90% of Nyquist automatically. The coefficient dialog also accepts a sample
period and an automatic upper frequency bound.

```scilab
// Selected DLR block or signal-only diagram; all discrete states share Ts.
[D, fig] = tfbode_xcos_discrete(scs_m, 0.1, 0.01, 4, "Hz");
// Automatic range below Nyquist (in rad/s):
[D, fig] = tfbode_xcos_discrete(scs_m, 0.1);
```

Supported discrete blocks: **DLR**, **DLSS**, scalar real **DOLLAR_m/DOLLAR_f**
unit delays, with real floating-point gains, sums, splits and I/O ports. Feedback
and cascades are supported. Selected blocks use their current parameter
expressions and diagram context, including `z` and context-defined coefficients.
All states are assumed to update synchronously once per supplied sample period.

For whole-diagram analysis, use a **signal-only analysis copy** with IN_f/OUT_f
ports and remove clock blocks and event wires. Selected-block analysis isolates
the block and does not require altering the original clock wiring. Sample timing
is supplied explicitly, not inferred from the diagram. Clocked/multirate or
mixed continuous/discrete diagrams are rejected.

Try `exec("demos/discrete_example.sce", -1)` for `1/(z-0.5)` with Ts = 0.1 s.
Frequency bounds must be strictly below `1/(2*Ts)` Hz or `pi/Ts` rad/s.

## Limits

Tested on **Scilab 2026.1.0 / Windows**. Rebuild the source for other versions; they are not verified. Xcos analysis requires a scalar input. Continuous analysis uses zero-state/zero-input linearization; for nonlinear continuous systems supply an operating point through `tfbode_xcos(scs_m, lo, hi, units, x0, u0)`. Discrete analysis supports only the linear block set described above, at one sample period.

The discrete path builds an equivalent state-space interconnection using
continuous proxy blocks, then assigns the original discrete sample period. It
preserves the discrete A/B/C/D equations; it does not discretize a continuous plant.

## Development

Run `tests/run.sce`, `tests/xcos.sce` and `tests/discrete.sce` in separate Scilab processes (each exits when finished). Start development sessions with `-noatomsautoload` if another TFBode release is installed, so its protected library does not shadow branch macros. Run `package.ps1` after building, then `tests/package.sce` to check the archive. No C compiler or extra toolbox is required. Restart Scilab after installing a new version.

BSD-3-Clause. See [LICENSE](LICENSE). Review notes: [REVIEW.md](REVIEW.md).

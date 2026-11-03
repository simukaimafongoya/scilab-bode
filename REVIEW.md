# Review of 0.3.0

Reviewed every authored macro, loader hook, builder, packaging script, demo,
test, metadata file and documentation file. Generated loader/cleaner scripts
come from Scilab's toolbox builder.

## Changes

- Documented that the numerical algorithms are Scilab's native `bode` and
  `lincos`; this toolbox adds convenience and Xcos menu integration.
- Replaced machine-specific README paths with portable installation steps.
- Added a one-command source installer; retained a normal local ATOMS ZIP.
- Package version comes from DESCRIPTION, with fresh staging for every build.
- Reject multi-input models and invalid/unspecified sample periods before plotting.
- Reset the dialog result on cancellation after an invalid entry.
- Validate custom operating-point argument pairs and event-driven superblocks.
- Keep generated binaries, test images and local build outputs out of Git.

## Verification

Tests exercise compilation/loading, coefficient order, input validation,
Hz/rad/s plotting, discrete Nyquist checks, Xcos single-block and cascade
responses against analytical systems, diagram context and archive relocation.
The Xcos UI was also exercised by the user in Scilab 2026.1.

## Remaining limits

Only Scilab 2026.1.0 on Windows is verified. Xcos linearization supports
continuous diagrams and uses zero state/input unless an operating point is
provided. Diagram context is normal executable Scilab code. Numeric coefficient
dialog input is parsed as numbers, not executed. Xcos menus persist until the
Scilab session ends; restart after unloading or updating the toolbox.

The local ATOMS package is distinct from publication in the ATOMS catalogue.

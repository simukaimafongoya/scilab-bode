# Review of 0.3.0

## Feature branch 0.4.0: discrete systems

Adds discrete coefficient entry, DLR/DLSS/scalar-delay analysis and single-rate
linear interconnections through a state-space proxy. Sample time is explicit;
event wiring, mixed dynamics, integer signals and unsupported blocks are rejected.
The discrete test suite compares cascades, feedback, gains, state-space and delays
against analytical z-domain systems and checks Nyquist and sample-time scaling.
Continuous regression tests and relocated package tests are retained.

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

Only Scilab 2026.1.0 on Windows is verified. Continuous Xcos linearization uses
zero state/input unless an operating point is provided. Discrete analysis is
limited to synchronous real linear blocks and signal-only analysis copies.
Diagram context is normal executable Scilab code. Numeric coefficient
dialog input is parsed as numbers, not executed. Xcos menus persist until the
Scilab session ends; restart after unloading or updating the toolbox.

The local ATOMS package is distinct from publication in the ATOMS catalogue.

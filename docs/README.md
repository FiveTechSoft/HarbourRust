# HarbourRust documentation

Start with the [repository overview](../README.md) for the current marker and
a minimal Linux build. Detailed records are separated here so the front page
stays short.

## Current state and limits

- [Diagnostic baseline - 2026-11-13](BASELINE-2026-11-13.md): current admission and
  exact-output results, inherited failures, scope limits, reproduction and
  published increment records. This is the current marker, not a completion percentage.
- [Build and test instructions](../BUILDING.md): Linux build, Windows cross-build,
  Wine, binary provenance and the regression runner.

## Technical and historical records

- [Development history](DEVELOPMENT-HISTORY.md): the full former root README,
  including iteration history, ownership, supported syntax, technical details,
  validation claims and limits. Historical claims remain dated; use the baseline
  above for the current marker.
- [Battery record](BATTERY.md): detailed historical battery notes and protocols.
- [Evidence overview](../EVIDENCIA.md).
- [Historical hk source index](../probes/legacy-hk/README.md) and
  [status/output table](../3-MANIFEST.md).
- [Oracle records](../oraculos/) and [other probes](../probes/).
- [Design notes](../design/) and [experiments](../experiments/).

- [Former main development history](MAIN-DEVELOPMENT-HISTORY.md): the separate
  main README, including its historical Date work, preserved during integration.
- [Independent Date port](DATE-PORT-2026-11-13.md): current representation and limits.

## Source and tests

- [Compiler source](../src/).
- [Examples](../ejemplos/).
- [Regression manifest](../tests/manifest.txt) and [runner](../tests/run_battery.sh).

No source, historical text or test expectation is removed by this documentation
reorganization. Relative links in the moved README are adjusted for its new location.

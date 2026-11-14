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
- [Evidence overview](../EVIDENCE.md).
- [Historical hk source index](../tests/probes/legacy-hk/README.md) and
  [status/output table](../3-MANIFEST.md).
- [Oracle records](../tests/oracles/) and [other probes](../probes/).
- [Design notes](../design/) and [experiments](../experiments/).

- [Former main development history](MAIN-DEVELOPMENT-HISTORY.md): the separate
  main README, including its historical Date work, preserved during integration.
- [Independent Date port](DATE-PORT-2026-11-13.md): current representation and limits.

## Source and tests

- [Compiler source](../src/).
- [Examples](../tests/samples/).
- [Regression manifest](../tests/manifest.txt) and [runner](../tests/run_battery.sh).

No source, historical text or test expectation is removed by this documentation
reorganization. Relative links in the moved README are adjusted for its new location.

## Increment and design records

- [Classes and objects](CLASSES.md); [threads and mutexes](THREADS.md).
- [Read-only DBF](DBF-READONLY.md); [NTX](NTX-READONLY.md); [CDX](CDX-READONLY.md); [hbmk2 adapter](HBMK2-ADAPTER.md).
- [Console LF boundaries](CONSOLE-LF-2026-11-14.md); [ProcName/ProcLine metadata](PROC-METADATA-2026-11-14.md); [hash string ownership](HASH-STRING-OWNERSHIP-2026-11-14.md).
- [VAS-backed flat arrays](vas-arrays-v1.md); [dynamic ownership](DESIGN-dynamic-ownership.md); [hash design](DESIGN-hashes.md); [NIL tag](DESIGN-nil-tag.md).
- [C Extend bridge](EXTEND-BRIDGE.md); [H2 binding](EXTEND-BRIDGE-H2-BINDING.md); [H2 callbacks](EXTEND-BRIDGE-H2-CALLBACKS.md).
- [Differential method](DIFFERENTIAL.md); [preprocessor F0](PP-F0.md); [string concat benchmark](BENCH-strcat.md).
- [Goose memory impact](GOOSE-MEMORY-IMPACT-2026-11-13.md); [Goose hybrid design](harbourrust-goose-hybrid-design.md).

- [Host target default and limits](HOST-TARGET-DEFAULT.md)

- [Experimental Intel Mach-O and native ARM64 limits](MACHO-INTEL.md)

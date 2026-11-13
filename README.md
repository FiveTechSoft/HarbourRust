# HarbourRust

A proof-of-concept compiler for a growing subset of Harbour syntax, written in
Rust. The ordinary backend emits x86-64 assembly for native executables.
Unsupported forms fail closed. This is not a complete Harbour compiler.

## Current status

The latest reviewed increment admits unchanged `tests/curdirt.prg` on Linux
and fixes deferred trailing-space output. Against the pinned Harbour source:

- **31/268** originals under `tests/` compile, or **31/1041** across the full inventory.
- **29/31** fresh executions match stdout, stderr and exit status exactly.
  The other two open error dialogues and time out; they are not passes.
- Linux regression manifest: **1635/1639**, with the same four inherited failures.

These are bounded measurements, not a project completion percentage. Windows,
LLVM and interactive-terminal support have separate limits. Source and probe
changes are reviewed independently before publication.

See the [current baseline](docs/BASELINE-2026-11-13.md) for evidence, caveats,
known failures and the history of published increments.

## Build and run on Linux

Requires Rust and GNU binutils on Linux x86-64. From the repository root:

```sh
rustc --edition=2021 -O src/hbc.rs -o hbc
./hbc ejemplos/hola.hb hola.s --target=linux
as -o hola.o hola.s
ld -o hola hola.o
./hola
```

The compiler build uses Rust's standard library; no Cargo dependencies are
needed. [Build instructions](BUILDING.md) cover Windows cross-compilation,
Wine, prebuilt-binary caveats and the test runner. Rebuild from current source
rather than assuming the older prebuilt binaries match HEAD.

## Documentation and examples

- [Documentation index](docs/README.md): current results, technical history and protocols.
- [Development history](docs/DEVELOPMENT-HISTORY.md): the former long README, preserved.
- [Examples](ejemplos/): Harbour programs for the supported subset.
- [Regression manifest](tests/manifest.txt) and [runner](tests/run_battery.sh).
- [Historical hk probes](probes/legacy-hk/README.md): 99 PRGs moved out of the root, unchanged.
- [License](LICENSE): MIT.

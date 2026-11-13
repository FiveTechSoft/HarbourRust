# HarbourRust

HarbourRust is an ahead-of-time compiler for Harbour, written in Rust. It translates Harbour source directly into x86-64 assembly and produces native executables: no VM, no interpreter. Support grows construct by construct, with byte-for-byte checks against the original Harbour compiler wherever applicable and explicit records of known differences. Unsupported syntax is rejected explicitly at compile time.

## Current status

The current compiler includes the independently reviewed Date/CToD port and
the CurDir/trailing-space work. Against the pinned Harbour source:

- **31/268** originals under `tests/` compile, or **31/1041** across the full inventory.
- **29/31** fresh executions match stdout, stderr and exit status exactly.
  The other two open error dialogues and time out; they are not passes.
- Linux regression manifest: **1657/1661**, with the same four inherited failures.

These are bounded measurements, not a project completion percentage. Windows,
LLVM and interactive-terminal support have separate limits. Source and probe
changes are reviewed independently before publication.

Linux `Date()` remains UTC, not local time. Date parameters and general dynamic
Date storage are not supported; Windows runtime for the new port is unverified.
See the [Date port record](docs/DATE-PORT-2026-11-13.md) for the exact scope.

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

## Build and run on Windows

Use a Windows `hbc.exe` built from current source following
[BUILDING.md](BUILDING.md#4-build-the-compiler-itself-as-a-windows-exe-hbcexe).
Install MinGW-w64 binutils and the KERNEL32 import library; put
`x86_64-w64-mingw32-as` and `x86_64-w64-mingw32-ld` on `PATH`.
From Windows Command Prompt at the repository root, with `hbc.exe` there:

```bat
set "HBC=%CD%\hbc.exe"
dist\compile.bat ejemplos\hola.hb hello
hello.exe
```

The script chains `hbc.exe` -> assembler -> linker and stops on failure.
`HBC` overrides its default older `dist\2-hbc.exe`; see the build instructions
for prebuilt-binary provenance. Historical Windows binary checks used Wine
10.20, not real Windows. The batch script itself has not been tested end to
end on real Windows or under Wine. No current-HEAD Windows pass is implied.

## Documentation and examples

- [Documentation index](docs/README.md): current results, technical history and protocols.
- [Development history](docs/DEVELOPMENT-HISTORY.md) and [former main history](docs/MAIN-DEVELOPMENT-HISTORY.md): both long READMEs, preserved.
- [Examples](ejemplos/): Harbour programs for the supported subset.
- [Regression manifest](tests/manifest.txt) and [runner](tests/run_battery.sh).
- [Historical hk probes](probes/legacy-hk/README.md): 99 PRGs moved out of the root, unchanged.
- [License](LICENSE): MIT.

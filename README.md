# HarbourRust

HarbourRust is an ahead-of-time compiler for Harbour, written in Rust. It translates Harbour source directly into x86-64 assembly and produces native executables: no VM, no interpreter. Support grows construct by construct, with byte-for-byte checks against the original Harbour compiler wherever applicable and explicit records of known differences. Unsupported syntax is rejected explicitly at compile time.

## Current status

Fresh Linux regression check on main: **1096/1097**. The inherited failure is
`tests/t110_pp_include_angle_neg.hb` (negative diagnostic mismatch).
This is a regression result, not a compatibility percentage. Windows, LLVM,
and all upstream Harbour programs are not covered by that number.

## Build and run on Linux

Requires Rust and GNU binutils on Linux x86-64. From the repository root:

```sh
rustc --edition=2021 -O src/hbc.rs -o hbc
./hbc ejemplos/hola.hb hola.s --target=linux
as -o hola.o hola.s
ld -o hola hola.o
./hola
```

See [build instructions](BUILDING.md) for platform-specific details and the
regression runner. Rebuild from source rather than assuming prebuilt binaries
match the current compiler.

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

- [Documentation index](docs/README.md).
- [Development history](docs/DEVELOPMENT-HISTORY.md): former long README, preserved.
- [Examples](ejemplos/) and [regression manifest](tests/manifest.txt).
- [Historical hk probes](probes/legacy-hk/README.md): 99 PRGs moved from root, unchanged.
- [License](LICENSE): MIT.

# HarbourRust

Write Harbour. Run native. Rust architecture.

![Harbour 4 Flash Edition](assets/harbour4-flash-edition.jpg)

HarbourRust is an ahead-of-time compiler for Harbour, written in Rust. It translates Harbour source directly into x86-64 assembly and produces native executables: no VM, no interpreter. Support grows construct by construct, with byte-for-byte checks against the original Harbour compiler wherever applicable and explicit records of known differences. Unsupported syntax is rejected explicitly at compile time.

## Memory model

No VM, no pcode, no garbage collector. Ownership checked at compile time, with deterministic release and no pause times; one limited persistent-value path uses reference counting (see below). In the same family of GC-free designs as Rust and the recent Goose language.

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
Date storage are not supported. Windows smoke tests cover `CToD`, blank dates and
`ValType` under Wine 11.0. The full Linux + Wine regression runner has now
been run against main and the bridge increment: both report 1643 passes and
27 failures, with no new failure cases and all five extra harnesses passing.
This is not real-Windows verification or a green Windows battery.
See the [Date port record](docs/DATE-PORT-2026-11-13.md) for the exact scope.

See the [current baseline](docs/BASELINE-2026-11-13.md) for evidence, caveats,
known failures and the history of published increments.

## What the native path does not need

| Component | HarbourRust ordinary AOT | Harbour pcode | Harbour `-gc3` |
| --- | --- | --- | --- |
| Harbour VM / HVM | No | Yes | Harbour VM/runtime services remain |
| Pcode and its runtime interpreter | Neither | Pcode executed by the VM | Direct C for generated function bodies; Harbour runtime services remain |
| Tracing garbage collector | No | Harbour runtime GC | Harbour runtime GC |
| Harbour runtime/RTL linkage | Own embedded native helpers for the supported subset, not the full Harbour runtime | Harbour runtime/RTL | Harbour runtime/RTL |
| C Extend API | C Extend API bridge: milestone 1 available on Linux (verified byte-exact against official Harbour and real hbmk2); Windows in progress. | Supported | Supported |

No tracing GC does not mean no memory management: native allocation/free helpers manage supported values, and a limited persistent-value path uses reference counting. This is not full Harbour dynamic-sharing compatibility. `-gc3` generates C calls to Harbour's runtime helpers; it does not turn Harbour into the same freestanding native model as HarbourRust.

## Use the release without Rust or a C compiler

Download the prebuilt `hbc` (Linux x86-64) or `hbc.exe` (Windows x86-64) from [v0.1.1](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.1.1). **Neither Rust nor a C compiler is needed to use these binaries or to build the supported native-only examples.** The ordinary path is Harbour source -> `hbc` -> assembly -> GNU `as` -> GNU `ld` -> native executable. Linux needs GNU binutils; Windows needs MinGW-w64 binutils and its KERNEL32 import library, with the tool names required by `build.bat` on `PATH`.

The release also includes `hello.exe`, `arrays_hashes.exe` and `dates.exe`: run these Windows samples directly without a compiler, assembler or linker. They were tested under Wine 11.0, not on real Windows. The compiler binaries have OS/library requirements listed in the release notes. Building `hbc` itself from source requires Rust; building and linking C extensions with the Linux milestone-1 bridge requires a C toolchain, which is outside the native-only path. The bridge is in current source, not in the older v0.1.1 compiler binaries.

## Harbour standard-function compatibility

HarbourRust provides a growing native compatibility layer for the supported subset of Harbour's standard functions, including `QOut`/`QQOut`, `Len`, `AAdd`/`ASize`, hash operations and `Date`/`CToD`. These functions use Harbour-compatible names and measured behavior where supported, with explicit limits and known differences. This is not the complete Harbour runtime or a general implementation of Harbour's C Extend API; arbitrary Harbour libraries are not currently plug-compatible. The [Linux milestone-1 C bridge](docs/EXTEND-BRIDGE.md) supports scalar integer, logical, string and NIL arguments and returns through a measured subset of `hb_par*`/`hb_ret*`. Arrays, dates, floating point, by-reference arguments and callbacks are outside this milestone; Windows support is planned.

## Recorded executable size and speed

**The recorded native samples are much smaller and faster on these workloads.** These are historical Linux microbenchmarks from 25 October 2026, not measurements of today's release or a claim about every Harbour application.

| Measurement | HarbourRust | Harbour pcode | Harbour -gc3 |
| --- | ---: | ---: | ---: |
| `b3_call` executable size, unstripped Linux ELF | **9,032 bytes** | 1,431,608 bytes | 1,431,560 bytes |
| `b3_call` execution time, median | **33 ms** | 1,591 ms | 972 ms |
| `b2_str` execution time, median | **520 ms** | 865 ms | 745 ms |

For `b3_call`, the recorded artifact is about **158 times smaller**, and the timing rerun is **48 times faster than pcode** or **29 times faster than -gc3**. Size and timing use different HarbourRust revisions; they must not be combined into a current-release claim.

Method: Linux x86-64, 2 cores/2 GB RAM; median of five runs, matching outputs checked before timing; Harbour `694428e1` with hbmk2 default `-O3`; HarbourRust `ca760e0a` for timings and `99f32d8f` for sizes. The Harbour binaries include the broader RTL and use libc/libm; the native samples have a smaller freestanding runtime and a narrower capability set. No Windows EXE size comparison is claimed. The `b1_int` speed comparison was withdrawn because the two compilers used different numeric type paths.

See [recorded results and corrections](bench/RESULTS.md), [artifact sizes](bench/SIZES.md) and [methodology](bench/METHODOLOGY.md).

## Build and run on Linux

Requires Rust and GNU binutils on Linux x86-64. From the repository root:

```sh
rustc --edition=2021 -O src/hbc.rs -o hbc
./hbc tests/samples/hello.hb hello.s --target=linux
as -o hello.o hello.s
ld -o hello hello.o
./hello
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
dist\build.bat tests\samples\hello.hb hello
hello.exe
```

The script chains `hbc.exe` -> assembler -> linker and stops on failure.
`HBC` overrides its default older `dist\2-hbc.exe`; see the build instructions
for prebuilt-binary provenance. The v0.1.1 compiler, this batch script and real Windows binutils were tested
end to end under Wine 11.0 with the greeting, array/hash and date samples.
Their stdout, stderr and exit status match the Linux/Harbour checks. This is
a release smoke test, not real-Windows verification. The later source-level
Linux + Wine battery result and its inherited failures are recorded above.

## Documentation and samples

- [Documentation index](docs/README.md): current results, technical history and protocols.
- [Development history](docs/DEVELOPMENT-HISTORY.md) and [former main history](docs/MAIN-DEVELOPMENT-HISTORY.md): both long READMEs, preserved.
- [Samples](tests/samples/): Harbour programs for the supported subset.
- [Regression manifest](tests/manifest.txt) and [runner](tests/run_battery.sh).
- [Historical hk probes](tests/probes/legacy-hk/README.md): 99 PRGs moved out of the root, unchanged.
- [License](LICENSE): MIT.

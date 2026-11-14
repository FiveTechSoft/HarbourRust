# HarbourRust

Write Harbour. Run native. Rust architecture.

![Harbour 4 Flash Edition](assets/harbour4-flash-edition.jpg)

HarbourRust is an ahead-of-time compiler for Harbour, written in Rust. It translates Harbour source directly into x86-64 assembly and produces native executables: no VM, no interpreter. Support grows construct by construct, with byte-for-byte checks against the original Harbour compiler wherever applicable and explicit records of known differences. Unsupported syntax is rejected explicitly at compile time. Harbour sources in this repository use the standard `.prg` extension.

## Memory model

No VM, no pcode, no garbage collector. Ownership checked at compile time, with deterministic release and no pause times; one limited persistent-value path uses reference counting (see below). In the same family of GC-free designs as Rust and the recent Goose language.

## Current status

The current compiler includes the independently reviewed Date/CToD port,
the CurDir/trailing-space work, and the bounded C Extend-System bridge (v9)
on Linux and Windows x64 (Windows verified under Wine 11.0, not on real
Windows). [v0.4.0](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.4.0)
also adds bounded read-only dBASE III DBF support on Linux x86-64.
[v0.5.0](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.5.0) adds
read-only NTX character-field indexes on the same backend. Main also includes
the bounded single-tag read-only CDX increment described below.
Against the pinned Harbour source:

- **31/268** originals under `tests/` compile, or **31/1041** across the full inventory.
- **29/31** fresh executions match stdout, stderr and exit status exactly.
  The other two open error dialogues and time out; they are not passes.
- Linux regression manifest: **1660/1661**, with only inherited `t110` remaining.
  The hash-default and nested-array shrink fixes resolve `t592`, `t385` and `t419`.
- DBF hito 1: **8/8** same-source programs match real Harbour stdout, stderr
  and exit status byte-for-byte. A separate C bridge probe verifies copied
  field values after closing the DBF workarea.

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

## Active development

The first DBF, NTX and CDX increments are released; classes and objects
are in main (v0.7.0). Broader RDD support remains
work in progress. No unmeasured speed or capability claims are made.

- **DBF support.** Read-only dBASE III tables are in main and v0.4.0: one
  workarea, C/N/L/D fields, `dbUseArea`, `FieldGet`, `dbGoTop`, `dbSkip`,
  `RecNo`/`LastRec`, `BOF`/`EOF`, `Deleted` and `dbCloseArea`, on Linux x86-64.
  This is an own MIT implementation, checked byte-for-byte against real Harbour.
  It is not standard RDD compatibility: no memo, writes/shared locking,
  Windows DBF, general static-Date/Dyn conversion or decimal arithmetic/comparison.
  Unsupported consumers fail explicitly.
- **NTX support.** Read-only NTX is in main and v0.5.0: one ascending,
  nonunique, unconditional index over a direct C field; OrdListAdd/Clear,
  top/bottom/skip and DbSeek/Found, with duplicate/prefix/softseek/findLast
  behavior checked against real Harbour. Six same-source programs pass in
  both modes (**12/12** paired executions). Eager snapshot validation; no
  writes, calculated/noncharacter keys, multiple orders, Windows or LLVM.
  See [scope and tests](docs/NTX-READONLY.md).
- **CDX support.** Linux read-only, explicitly opened nonstructural compound
  CDX with exactly one ascending, nonunique, unconditional tag over a direct
  C field of at most 240 bytes. Same navigation/seek surface as NTX; no autoopen
  or implicit tag selection. Seven same-source programs pass in both modes
  (**14/14** paired executions), including C240 and a 20,000-record tree.
  CDX uses 512-byte pages, NTX 1024; empty-seek BOF differs by driver.
  Multi-tag/structural indexes and wider fields are explicitly rejected.
  See [scope, behavior and tests](docs/CDX-READONLY.md).
- **Classes and objects.** In main and v0.7.0, on Linux x86-64: `CREATE
  CLASS` / `CLASS ... FROM|INHERIT` with single inheritance, scalar `DATA`
  with lazy child-first `INIT`, methods and constructors (an implicit
  default `New()` when the class declares none), virtual dispatch through
  a flat per-class method table with hierarchy-wide constant slots
  (overrides patch the inherited slot in place), fixed-offset `DATA`
  access, Harbour sharing semantics for assignment and parameters,
  object identity `==`, and `? o` printing. Tag kind 13 is officially in
  use for objects. This is an own MIT implementation; Harbour serves as
  the test oracle only, and `#include "hbclass.ch"` is accepted and
  ignored (no Harbour header content is used). The public differential
  gate compiles and runs 26 same-source probes under real Harbour and
  HarbourRust with byte-identical output, plus 3 declared-limit probes
  and 13 named negatives (**42/42**). The landing kept the Linux
  regression manifest unchanged and produced byte-identical assembly for
  all class-free positive programs (no contamination); the runtime blob
  is AddressSanitizer/UBSan-clean. Measured, not promised: on four
  same-source microbenchmarks (2M method calls, 2M virtual dispatches,
  2M DATA read/writes, 500k create/release cycles), this build runs
  between **14x and 34x faster** than real Harbour (`694428e1`, hbmk2
  `-gtstd`, default optimization) on the same machine, outputs verified
  identical before timing, best of 3 runs. These are microbenchmarks of
  the supported subset; performance on arbitrary Harbour programs is not
  measured and not claimed. Declared limits (explicit compile-time
  rejections, never silent): scalar `DATA` only (no object or array
  members yet); single inheritance only - Harbour's multiple inheritance
  is a named rejection; members named like reserved words (for example a
  method named `Step`) are a named parser rejection; compound assignment
  (`+=`) is outside the expression subset; a method call on a value of
  statically unknown class is rejected unless the member belongs to
  exactly one class hierarchy in the program, which pins the receiver to
  that hierarchy's root class (Harbour resolves these at runtime);
  classes are Linux-only in this increment (`--target=windows` rejects
  them by name); `=` as an expression operator remains outside the
  supported subset, as before.
  See [scope, model and tests](docs/CLASSES.md).

- **Threads and mutexes.** In main and v0.8.0, on Linux x86-64: `hb_threadStart`/
  `Join`/`Wait`/`Self`/`Detach`/`WaitForAll` and mutex create/lock/unlock/eval/
  notify queues over an own clone(2)+futex runtime, one-shot initialization and
  the MT-aware object runtime. Public gates run same-source probes against real
  Harbour in both modes. Declared limits: Linux-only (`--target=windows` is a
  named rejection), literal thread arguments only, an error inside a thread
  prints to stderr and returns NIL instead of opening the interactive error box,
  `--instrument` with threads is rejected and `hb_memcheck` counters are
  approximate while threads run.
  See [scope and limits](docs/THREADS.md).

## What the native path does not need

| Component | HarbourRust ordinary AOT | Harbour pcode | Harbour `-gc3` |
| --- | --- | --- | --- |
| Harbour VM / HVM | No | Yes | Harbour VM/runtime services remain |
| Pcode and its runtime interpreter | Neither | Pcode executed by the VM | Direct C for generated function bodies; Harbour runtime services remain |
| Tracing garbage collector | No | Harbour runtime GC | Harbour runtime GC |
| Harbour runtime/RTL linkage | Own embedded native helpers for the supported subset, not the full Harbour runtime | Harbour runtime/RTL | Harbour runtime/RTL |
| C Extend API | Bounded C Extend API bridge on Linux and Windows x64 (verified byte-exact against official Harbour and real hbmk2; Windows under Wine 11.0, not real Windows). | Supported | Supported |

No tracing GC does not mean no memory management: native allocation/free helpers manage supported values, and a limited persistent-value path uses reference counting. This is not full Harbour dynamic-sharing compatibility. `-gc3` generates C calls to Harbour's runtime helpers; it does not turn Harbour into the same freestanding native model as HarbourRust.

## Use the release without Rust or a C compiler

Download the prebuilt `hbc` (Linux x86-64) or `hbc.exe` (Windows x86-64) from [v0.1.1](https://github.com/FiveTechSoft/HarbourRust/releases/tag/v0.1.1). **Neither Rust nor a C compiler is needed to use these binaries or to build the supported native-only examples.** Current-source `hbc` writes the native executable itself: Harbour source -> `hbc` -> native ELF (Linux x86-64) or PE32+ (Windows x86-64), with no external assembler or linker. The v0.1.1 binaries above predate that writer and still follow the older assembly -> GNU `as` -> GNU `ld` path, which current-source `hbc` keeps behind `--external-as`. The internal PE writer emits a console image with entry `_start`, fixed ImageBase `0x140000000` and imports limited to a measured kernel32 whitelist (`ExitProcess`, `GetEnvironmentVariableA`, `GetLocalTime`, `GetProcessHeap`, `GetStdHandle`, `HeapAlloc`, `HeapFree`, `WriteFile`); no CRT, SEH, TLS or base relocations are supported.

VAS-eligible programs add `GetSystemInfo`, `VirtualAlloc` and `VirtualFree` to this whitelist (11 entries); ineligible programs retain the original eight-entry whitelist.

The release also includes `hello.exe`, `arrays_hashes.exe` and `dates.exe`: run these Windows samples directly without a compiler, assembler or linker. They were tested under Wine 11.0, not on real Windows. The compiler binaries have OS/library requirements listed in the release notes. Building `hbc` itself from source requires Rust; building and linking C extensions with the bounded C bridge requires a C toolchain, which is outside the native-only path. The bridge is in current source, not in the older v0.1.1 compiler binaries.

## Harbour standard-function compatibility

HarbourRust provides a growing native compatibility layer for the supported subset of Harbour's standard functions, including `QOut`/`QQOut`, `Len`, `AAdd`/`ASize`, hash operations and `Date`/`CToD`. These functions use Harbour-compatible names and measured behavior where supported, with explicit limits and known differences. This is not the complete Harbour runtime or a general implementation of Harbour's C Extend API; arbitrary Harbour libraries are not currently plug-compatible. The [bounded C Extend bridge](docs/EXTEND-BRIDGE.md) covers scalar integers, doubles, logicals, strings and NIL, oracle-verified items, by-reference scalar arguments, read-only arrays and bounded C-to-codeblock callbacks, through a measured subset of `hb_par*`/`hb_ret*`/`hb_eval*`, on Linux and Windows x64 (Windows verified under Wine 11.0). Dates and hashes across the boundary, array mutation and resize, and array return values remain outside its scope.

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

Requires Rust on Linux x86-64 to build the compiler. From the repository root:

```sh
rustc --edition=2021 -O src/hbc.rs -o hbc
./hbc tests/samples/hello.prg hello --target=linux
./hello
```

`hbc` emits the ELF executable directly; GNU binutils are only needed for the
`--external-as` fallback (`as` + `ld -s`).

The compiler build uses Rust's standard library; no Cargo dependencies are
needed. [Build instructions](BUILDING.md) cover Windows cross-compilation,
Wine, prebuilt-binary caveats and the test runner. Rebuild from current source
rather than assuming the older prebuilt binaries match HEAD.

## Build and run on Windows

Use a Windows `hbc.exe` built from current source following
[BUILDING.md](BUILDING.md#4-build-the-compiler-itself-as-a-windows-exe-hbcexe).
No assembler or linker is required: `hbc.exe` writes the PE32+ image itself.
From Windows Command Prompt at the repository root, with `hbc.exe` there:

```bat
set "HBC=%CD%\hbc.exe"
"%HBC%" tests\samples\hello.prg hello.exe --target=windows
hello.exe
```

`--external-as` keeps the older MinGW-w64 `x86_64-w64-mingw32-as`/`-ld` path;
that toolchain is also used by the test runner. `dist\build.bat` chains the
legacy path and defaults to the older `dist\2-hbc.exe`; set `HBC` to override.
The internal writer was exercised on Windows 11 x86-64 with an isolated
native-manifest battery: 1638/1638 executed cases matched (1617 exact, 21
recorded as newline-normalized), with 23 Linux-only cases skipped and no
failures. This is a bounded manifest result, not a general compatibility
claim. The v0.1.1 compiler and batch script were tested under Wine 11.0 as a
release smoke test.

## Documentation and samples

- [Documentation index](docs/README.md): current results, technical history and protocols.
- [Development history](docs/DEVELOPMENT-HISTORY.md) and [former main history](docs/MAIN-DEVELOPMENT-HISTORY.md): both long READMEs, preserved.
- [Samples](tests/samples/): Harbour programs for the supported subset.
- [Regression manifest](tests/manifest.txt) and [runner](tests/run_battery.sh).
- [Historical hk probes](tests/probes/legacy-hk/README.md): 99 PRGs moved out of the root, unchanged.
- [License](LICENSE): MIT.

# Experimental LLVM scalar AOT gate

This branch is a feasibility test, not a replacement backend. Default `hbc`
behavior is unchanged. `--experimental-llvm` uses the same preprocessor, parser
and semantic/ownership checks, then emits LLVM IR for a deliberately small
scalar subset. LLVM verifies, optimizes and emits an object, linked with the
existing assembly runtime through target-C-ABI adapters. No JIT, VM or new
ownership/collection representation is introduced.

## Status and boundaries

Supported for this experiment: I64 function signatures/locals, integer + - *,
signed comparisons, IF, WHILE, FOR with its existing signed overflow termination,
user calls/recursion, lazy IIF, integer output and literal string output. Arithmetic
uses ordinary LLVM wrapping operations, never invented `nsw`/`nuw` promises.
FOR increment uses signed-overflow intrinsic and keeps the old counter on overflow.
Everything else is rejected by the existing checker or experimental emitter.
This is not full Harbour integer-promotion semantics beyond the current backend.

Not implemented: arrays, dynamic values, floats, owned strings, byref ABI,
EXIT/LOOP, most builtins including ProcLine, logical output, native Windows
compiler packaging, and per-statement diagnostic trace parity. The prototype
therefore cannot pass the full compatibility battery through LLVM. The normal
(nonexperimental) path passes 1081 manifest cases plus five harness checks on
Linux and Wine, with the frozen sweep unchanged at 20 COMPILES.

Diagnostic trace updates in the current backend are not emitted by the LLVM
path yet. Successful-output equality does not establish error-trace equality.
Do not replace the current backend or claim general Rust parity from these tests.

## Reproduce

Requirements: Rust, GNU binutils, Python3, an LLVM23 shared library exposing the
C API. Set `HARBOUR_LLVM_LIB` to that library and run:

```
bash experiments/llvm-scalar/run.sh
```

Optionally set `RUSTC`, `M` (MinGW bin dir), `MLIB` (MinGW import libraries),
`WINE` and its normal environment. Windows tests are cross-generated and run
under Wine, not native Windows. Run output is ignored by git. No automatic
installation or network download occurs. LLVM shared-library path is explicit;
the rustc-distribution C API used in this test is not a stable packaging contract.
The driver assumes LLVM23, X86 target, x86-64 baseline CPU, small code model,
static relocation and `default<O3>`. It fails if the required API is missing.

## Evidence, 27 October 2026

Environment: Linux x86-64, virtual Intel Xeon 2.60GHz, two visible CPUs;
rustc1.99.1 and LLVM23.1.1. Scalar corpus: accumulation, conditional accumulation,
recursive factorial and integer recurrence. Full corpus and edge-case output
match the current backend on Linux and Wine. Edge cases include negative steps,
zero-trip loops, lazy IIF and signed FOR counter overflow termination.
3063 scalar differential calls cover arguments -12..1000 and factorial -3..20.
Five print-adapter calls and a recursive LLVM call pass GPR/stack canaries on
Linux and GPR/stack/XMM6-15 canaries under Wine. No native-Windows result is claimed.

Kernel-only timings below are medians of 31 rotating-order samples after three
warmup rounds. Dynamic inputs cross a non-inlined function boundary; all results
are consumed. Rust uses matching wrapping arithmetic and checked FOR-counter
increment, with x86-64 baseline target and optimization3. This is a shared host,
not a dedicated benchmark machine. No confidence interval or general speed claim.

| Kernel | Existing backend | LLVM prototype | Rust equivalent |
| --- | ---: | ---: | ---: |
| Sum, 1M iterations | 2.453ms | 0.303ms | 0.303ms |
| Branch, 1M iterations | 3.342ms | 0.766ms | 0.763ms |
| Recurrence, 1M iterations | 3.146ms | 0.799ms | 0.929ms |

These current-backend times include its diagnostic trace updates, unlike the
other two. An explicitly labeled assembly-only no-trace control still showed
large scalar gaps, but layout/timing noise means subtracting the runs is not a
valid estimate of tracing cost. Raw samples and that control are in `results/`.
Factorial10 is only ~4ns in LLVM/Rust and ~71ns current, too small and narrow for
a headline; function/dispatch overhead matters. No vectorization, real application,
array/string workload, memory profile or Windows speed result is established.
LLVM scalar assembly keeps loop state in registers, removes local stack traffic,
and optimizes recursion; optimized Rust shows similar scalar patterns. A constant
whole-program case can eliminate its loop. Those are local findings, not a claim
that every Harbour program will have Rust-quality code.

| Same complete corpus executable | Current | LLVM prototype |
| --- | ---: | ---: |
| Linux file bytes | 22040 | 24816 |
| Windows file bytes | 20524 | 20788 |
| Linux stripped file bytes | 18392 | 21000 |

Linux LLVM executable has no dynamic section; Windows imports only KERNEL32.dll.
LLVM is not inside those programs. File size is not RSS: runtime data/BSS still
exists. The library used by the development driver is 208167760 bytes, external
to every generated executable. Compiler-with-LLVM distribution size is unmeasured.
The current Rust compiler frontend binary is ~5.7MB; that does not include the
external LLVM library. No universal size prediction follows from this corpus.

Full small-corpus Linux pipelines measured across 11 runs: current median12ms
(frontend, assembler, linker), prototype median91ms (frontend, Python driver,
LLVM load/optimization/object, adapter preparation, assembler, linker). These
include Python startup/library load, not an intrinsic LLVM-only compilation cost.
Original raw samples and generated assembly are preserved in `results/`.

## Decision

Promising evidence for a separate LLVM route on scalar compute, without forcing
large generated executables. Not evidence to migrate now. Next gates would be
trace/error parity, larger runtime/data workloads, robust dependency packaging,
full differential correctness and actual Windows validation. Any expansion of
ownership/representation or replacement of the backend remains a separate decision.

Official references:
- https://rustc-dev-guide.rust-lang.org/backend/codegen.html
- https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/LangImpl08.html
- https://llvm.org/docs/CodeGenerator.html
- https://www.llvm.org/docs/UndefinedBehavior.html
- https://doc.rust-lang.org/stable/std/hint/fn.black_box.html
- https://llvm.org/docs/CMake.html

## Trace parity follow-up (supersedes the untraced configuration above)

The experimental flag now emits native three-word trace records with the same
runtime chain as the existing backend. No value storage model changes. Records
link on entry, update original file/line before statements, update again before
WHILE tests, and unlink on every return. Updates are volatile so LLVM cannot
remove observable diagnostic state. ProcLine current-frame/literal0 uses the
existing physical-line map, including macro-separated statements and continued
lines. Prefix/postfix scalar increment expressions retain the existing clean
promotion-boundary error; standalone `x++` remains the existing parser's +1
assignment form, not an invented overflow check.

Four controlled-error fixtures compare stdout, exit1 and full callstack bytes
on Linux and Wine: nested calls, recursion, error after a completed call, and
included-file origins. Successful corpus, edge, ProcLine and ABI tests remain.
The ABI canary additionally checks trace-chain restoration after recursion.
This establishes these registered cases, not universal signal/crash/error parity.

Objects now use PIC relocation with the small code model; static relocation
with pointer globals produced COFF address32 overflow at the normal 64-bit PE
image base. Generated programs remain freestanding/no LLVM runtime dependency.

`--experimental-llvm-no-trace` is an explicit analysis-only control, not a product
replacement. The run script measures both, and builds a Rust control with matching
native trace entry/update/leave writes. Results are in `trace-comparisons.json`.
Traced LLVM sum measured0.605ms versus untraced Rust0.302ms in one linked harness.
In a separately linked harness with traced Rust the same LLVM sum measured0.389ms
versus Rust0.454ms. This large layout sensitivity is evidence not to claim a
precise speed multiple or general parity. Branch measured0.992ms LLVM versus
0.921ms traced Rust; recurrence0.771ms versus1.213ms. These are medians of31rotating
samples, not real applications or a dedicated-machine result. The previous
untraced near-Rust result is not transferable to diagnostic builds.

Next gates remain larger data/runtime workloads, broad error-path coverage,
repeatable dedicated-machine performance and packaging. No merge is recommended. Latest trace-enabled corpus file sizes: Linux24864bytes
versus22048current; Windows24032bytes (same-runtime corpus with trace globals).
These supersede the original untraced prototype sizes for the new configuration.

## Bounded correctness audit follow-up

Two experimental-only defects found by differential tests are fixed:
- FOR must store the initial counter before evaluating its bound. `for i := 1
  to i+2` previously used the old i in the bound. The new fixture also tests a
  bound that increments i, negative steps and the final counter.
- QOut/QQOut must remove trailing spaces from the final literal-string item.
  Interior strings retain their bytes and separators. The existing all-space
  final-string separator behavior is preserved, not silently changed.

`audit.hb` compares complete output on Linux and Wine for both fixes, argument
side effects before printing, lazy IIF, branch-local names and WHILE. Ten
fail-closed checks cover logical output through branches/IIF, float, array, NIL,
string variable, byref, unsupported builtin/logical operator/EXIT, and instrument.
`--instrument` with LLVM is now an explicit rejection: allocator-registry checks
must not be silently omitted. Native trace records initialize text/length before
publishing their address, matching the existing emitter's entry discipline.

This is a bounded audit, not a proof of compiler correctness. No scalar/runtime
surface was broadened to satisfy these tests. The default backend keeps its full
1086 checks and frozen sweep20 COMPILES. Main remains unchanged.

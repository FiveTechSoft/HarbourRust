# Experimental LLVM scalar AOT gate

This branch is a feasibility test, not a replacement backend. Default `hbc`
behavior is unchanged. `--experimental-llvm` uses the same preprocessor, parser
and semantic/ownership checks, then emits LLVM IR for a deliberately small
scalar subset. LLVM verifies, optimizes and emits an object, linked with the
existing assembly runtime through target-C-ABI adapters. No JIT, VM or new
ownership/collection representation is introduced.

## Status and boundaries

Current supported slice: I64/logical scalar function signatures/locals, integer + - *,
signed comparisons, logical .AND./.OR./.NOT. with short-circuit evaluation,
IF, WHILE, EXIT/LOOP, FOR with its existing signed-overflow termination, user calls and
recursion, left-to-right scalar sequences, lazy IIF, integer and literal-string output, ProcLine current-frame
or literal0, and fixed I64 stack-array literals/index reads/writes/len.
Arithmetic uses wrapping LLVM operations, without invented nsw/nuw promises.
Native three-word trace frames preserve the tested diagnostic paths. See the
dated follow-ups below for the evidence and historical configurations.

Still rejected: dynamic values, floats, owned strings, byref ABI,
most builtins, dynamic/growing/nested arrays, array parameters
and whole-array copies. No native-Windows compiler packaging is provided.
This is not full Harbour integer-promotion semantics or a replacement backend.
The normal backend is unchanged; its latest full battery re-run is documented
below. The LLVM path cannot pass the full language compatibility battery.

## Reproduce

Requirements: Rust, GNU binutils, Python3, an LLVM23 shared library exposing the
C API. Set `HARBOUR_LLVM_LIB` to that library and run:

```
bash experiments/llvm-scalar/run.sh
```

Routine run.sh checks correctness without timing samples. To run the historical
measurement harness explicitly, set RUN_BENCHMARKS=1 (and optionally BENCH_N).
A timing run does not by itself establish comparable results across hosts/layouts.

Optionally set `RUSTC`, `M` (MinGW bin dir), `MLIB` (MinGW import libraries),
`WINE` and its normal environment. Windows tests are cross-generated and run
under Wine, not native Windows. Run output is ignored by git. No automatic
installation or network download occurs. LLVM shared-library path is explicit;
the rustc-distribution C API used in this test is not a stable packaging contract.
The driver assumes LLVM23, X86 target, x86-64 baseline CPU, small code model,
static relocation on Linux, PIC on Windows, and `default<O3>`. It fails if the
required API is missing. The target-specific relocation policy is explained below.

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

At this stage objects used PIC relocation with the small code model; static relocation
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

## Retained-layout sensitivity study

Run `run.sh` first, then run each selection separately (about30seconds on the
recorded machine):

```
STUDY_LAYOUT=0 python3 experiments/llvm-scalar/layout_study.py
STUDY_LAYOUT=1 python3 experiments/llvm-scalar/layout_study.py
STUDY_LAYOUT=2 python3 experiments/llvm-scalar/layout_study.py
```

The study pins each process to each available CPU, uses10M dynamic iterations
with3calls per sample and31rotating samples after3warmups. All three paths have
native trace writes. It links the IDENTICAL current and LLVM objects for every
selection; a retained text prefix shifts LLVM code0/32/64bytes. Linker symbol
addresses and object hashes are saved. The script checks that the prefix is
retained and the LLVM function begins at the expected16-byte aligned position.
This is a sensitivity test, not a proposed product padding fix. No source/IR
optimization is changed. New runs overwrite their layout selection's local data.

Recorded addresses of ll_sumloop:0x251f40,0x251f60,0x251f80, with the same
study_padding symbol0x251f3f and fixed Rust/current addresses. Sum LLVM/Rust
trace-equivalent median ratio is about0.86 in layouts0/2 but1.34 in layout1,
reproduced on both available CPUs. Thus one layout makes LLVM faster, another
slower than the Rust control. Branch is usually near1.00, recurrence near0.63;
a layout0/CPU1 run also has a branch outlier near0.75 and sum near1.00. Those
results are preserved, not dropped. Factorial10 remains too short for a headline.
Raw samples, per-run medians, CPU affinity, object hashes and symbols are under
`results/layout-study/`. Shared-host variability remains; these are not
confidence intervals, a dedicated-machine result or application-level parity.

An earlier local padding attempt was DISCARDED as a layout test because linker
GC removed its anonymous padding and all function addresses stayed unchanged.
Its repetitions were never evidence for three layouts. This retained-prefix
script specifically checks that failure mode before timing. Findings support
optimizing capability but do not support a general 'as fast as Rust' claim or
a replacement decision. No compiler/main/runtime change is part of this study.

## Fixed I64 array vertical follow-up, 28 October 2026 (new host, new baseline)

Different host and toolchain than the 27 October study: rustc 1.99.1 (same
version), libLLVM 23.1.5 from the official apt.llvm.org package (was 23.1.1).
Numbers below are a NEW baseline and are only comparable within this section.

Language slice added under --experimental-llvm only: fixed-size stack arrays
of I64 (literal initialization, a[i] reads, a[i] := v writes, len(a)), with
the same 1..=k bound checks and the same hbc_bound_error failure mode as the
current backend, and the same 3-word native trace frames. Write evaluation
order is value-then-index, matching the current backend (probe adv2).
Still fail-closed, with explicit rejection tests: dynamic Array(n), AAdd
growth, nested arrays, array parameters, whole-array copies, FOR EACH.

Correctness: arraywork.hb joins the exact-output differential set (Linux);
error-bound.hb and error-bound-write.hb compare stdout/stderr/exit 1
byte-exact against the current backend, including the trace callstack.
validate.rs runs 4076 differential calls (1013 of them arraywalk).

Workload: arraywork.hb arraywalk(n): a fixed 16-element I64 array,
n iterations of a[j] := a[j] + i with rotating j (bounds-checked every
access), then a full reduce with len(a). Trace-equivalent medians
(31 samples after warmup, CPU pinned, input 1M, ns/call):

  kernel     current     LLVM    Rust-traced   LLVM/Rust
  arraywalk  4026689   1192244       1229630      0.97   (CPU0)
  arraywalk  4020905   1229315       1228588      1.00   (CPU1)

Read: on this host and this kernel the LLVM backend with traces runs at
about the same time as the equivalent traced Rust control, while the
current backend with traces is slower in this workload. This is a
single-kernel, single-host result; it is not a general parity claim and
not a closed gate.

Code quality: disassembly shows both LLVM and rustc eliminate the
redundant 1..=16 bound checks inside the loop (both prove j stays in
range) while keeping the volatile trace stores and the FOR overflow
intrinsic. The remaining inner-loop cost is dominated by the trace
bookkeeping itself in all three implementations.

Larger data workload (same follow-up): arraywalk2 adds a fixed
256-element I64 array, n iterations of a[j] := a[j] + i with j advancing
17 slots per step (visits every element, crosses cache lines), then a
full reduce. Same measurement method, input 1M:

  kernel      current     LLVM    Rust-traced   LLVM/Rust
  arraywalk2  4407691   1238324       1285116      0.96   (CPU0)
  arraywalk2  4447034   1238616       1282729      0.97   (CPU1)

The LLVM time is essentially unchanged from the 16-element kernel
(data fits L1/L2 in both), while the traced Rust control moved up; the
16-element Rust control median also drifted between runs (1.23 vs 1.55
ms), another instance of the host variability already registered. Read:
close times between LLVM and traced Rust with real data access and
checks, not a closed gate. validate.rs now runs 5089 differential calls.

Windows cross-check: RESOLVED on this host without privileges - see the
next section. The 27 October layout-sensitivity caveats still apply:
percentages move with code layout and host.

## Windows validation route resolved, 28 October 2026 (userspace Wine, no privileges)

The cross-check left open above is closed on this host without sudo, admin
changes or spend, using only user-space downloads extracted under /tmp.

Tool provenance (verifiable):

- Wine: Kron4ek Wine-Builds release 10.0, asset
  `wine-10.0-amd64-wow64.tar.xz`
  (https://github.com/Kron4ek/Wine-Builds/releases/download/10.0/wine-10.0-amd64-wow64.tar.xz),
  extracted to /tmp/wine-10.0-amd64-wow64. WINEPREFIX must point at a
  user-owned directory: Wine refuses a prefix inside root-owned /tmp.
- MinGW binutils + kernel32 import library: Ubuntu packages
  `binutils-mingw-w64-x86-64` 2.38-3ubuntu1+9build1 (amd64) and
  `mingw-w64-x86-64-dev` 8.0.0-1 (all) from archive.ubuntu.com, extracted
  with dpkg -x to /tmp/mingw (used as M=/tmp/mingw/usr/bin,
  MLIB=/tmp/mingw/usr/x86_64-w64-mingw32/lib).
- libLLVM 23.1.5 + libz3: official apt.llvm.org packages extracted to
  /tmp/llvm23, used via LD_LIBRARY_PATH / HARBOUR_LLVM_LIB (no install).
- rustc 1.99.1 via rustup in the user profile.

Discarded routes (recorded so they are not retried blindly): Kron4ek
wine-11.20 plain amd64 needs the 32-bit loader /lib/ld-linux.so.2, absent
on this host; wine-11.20 wow64 SIGSEGVs during early ntdll initialisation.
The 10.0 wow64 build runs every PE binary used here.

New verification on this host (28 October 2026, distinct from the
historical 27 October runs): `tests/run_battery.sh` re-run in full with
M/MLIB/WINE set - 1086 manifest rows PASS, 0 FAIL (ALL GREEN), Linux +
Wine byte comparison. This experiment's `run.sh` with WINE set: 26 PASS /
0 FAIL, including byte-exact Windows output for corpus, audit, edge,
procline and arraywork, the Windows ABI canary, and the Windows
ERROR TRACE EXACT cases (increment overflow, array bound error) comparing
the current backend against LLVM.

Caveat: this is validation under Wine (user-space emulation of the Windows
API), not native Windows. It validates byte equality of the PE target and
its failure modes; it says nothing about behaviour or performance on real
Windows.

## Short-circuit control-flow increment, 29 October 2026

The experimental emitter now supports .AND., .OR. and .NOT. in the existing
logical/I64 value model, without adding signatures, ownership rules or runtime
helpers. AND/OR lower to conditional branches before evaluating the RHS; the
merge normalizes the result to 0/1. NOT inverts the normalized condition.
Logical output remains outside the slice; logical function signatures were added
in the later logical-call increment.

`logic.hb` covers all eight three-input truth combinations, nested operators,
logical-local assignments, IIF value contexts, WHILE termination, prefix
increment effects, ordered calls, and skipped invalid array indices. Its
88 integer outputs are checked against an independent Python truth/effect
oracle (including 27 signed input triples through an I64 function), in addition to byte-exact comparison against the current backend.
The compiler's current-backend short-circuit implementation and the existing
`t601_shortcircuit.hb` regression establish the expected lazy evaluation.
`error-logic-and.hb` and `error-logic-or.hb` cover RHS bounds failures that MUST
execute, including full nested callstack bytes and exit1. The fixtures use
variable indices so the existing static checker does not reject the program
before runtime. I64 helper parameters use arithmetic to pin inference; no
parameter-inference change is part of this increment.

The successful fixture is checked on Linux and PE under Wine; both error
fixtures are checked against the current backend on both targets. All prior
5089 differential calls and ABI canaries remain part of run.sh. No new
performance claim or Rust comparison follows from this control-flow increment.
The same host/toolchain and Wine limitations as the 28 October run apply.

Fresh result for this increment: run.sh reports 28 PASS lines, including the
independent logic oracle; 5089 prior function comparisons pass, and eight
controlled-error fixtures match on each target (16 exact error comparisons).
The normal backend battery was rebuilt and re-run: 1086 PASS, zero FAIL.
Disassembly of the parameterized logiccode function shows no logical-result
stack spills after optimization (trace-frame storage remains); pure conditions
become setcc/cmov/bit operations. That local code-quality observation is not a
Rust comparison or a performance result. Side-effecting operands are tested
separately, where their required evaluation order must remain observable.

## EXIT/LOOP increment, 29 October 2026

EXIT branches to the innermost loop end. LOOP branches to the WHILE test or
FOR increment as appropriate; FOR retains its checked signed-overflow
termination, including preserving the old counter at both signed limits.
A stack of lowering destinations handles nesting without changing runtime
values, ownership or trace-frame layout. Function return still unlinks its
trace frame; EXIT/LOOP do not unlink the function they remain inside.

`loopcontrol.hb` checks forward/reverse FOR, WHILE, both nesting orders,
both terminating IF arms, skipped code, zero-trip loops, signed-max/min
increment termination and early returns. Complete output is compared with
the current backend in Linux and under Wine, plus 33 explicit expected
integer observations. Existing regressions t28/t42/t48/t49 define the
innermost-loop and continue-to-increment semantics. `error-loopcontrol.hb`
checks the exact diagnostic callstack after nested EXIT/LOOP and a completed
early-returning function; error-loop-test.hb checks WHILE-test origin on the
next iteration reached by LOOP. EXIT/LOOP outside a loop still fail in analysis.
This does not add FOR EACH or admit ownership-bearing loop bodies to LLVM.

Fresh result: run.sh 32 PASS lines, zero failures, with 5089 prior differential
calls, the two independent output checks, and ten error fixtures on both targets
(20 exact diagnostic comparisons). Normal-backend battery rebuilt/re-run:
1086 PASS, zero FAIL. This increment has no speed, size or Rust-quality claim.

## Fail-closed unreachable-tail audit, 29 October 2026

Audit after EXIT/LOOP found an experimental boundary defect: lowering stopped
at the terminator, so unsupported syntax in a later, unreachable statement
could be accepted without the promised experimental-slice diagnostic. No
wrong execution was observed, but acceptance contradicted the slice contract.
This also affected RETURN inside a nested block before the EXIT/LOOP change.

The emitter now checks each terminated tail using a discarded copy of the
same lowering state, including locals and enclosing loop targets. It emits
no dead IR into the actual module. This reuses the exact support checks rather
than maintaining a second, potentially divergent syntax whitelist. Regressions
reject dead strings after EXIT, RETURN and a two-terminated-arm IF; division
after LOOP; and an unsupported builtin behind consecutive terminators.
Supported unreachable statements in loopcontrol.hb still compile and remain
unexecuted. Default code generation and all frontend semantics are unchanged.

Fresh audit result: run.sh 37 PASS lines, 5089 function comparisons and 20
exact diagnostic comparisons pass; rebuilt normal battery 1086 PASS, zero
failures. The five new rejection fixtures run on both emission targets.
No performance or size claim is added by this validation-only correction.

## Tagged logical-array boundary correction, 29 October 2026

A type-boundary audit found an experimental wrong-output case: {.T.,.F.}
was admitted by the emitter's literal-shape collection as a fixed I64 array.
The checked frontend actually classifies a literal containing logicals as
Ty::DArr with tagged cells; the current backend prints .T., while the
experimental lowering erased the tag and treated the element as integer1.
That path was outside the intended fixed-I64 slice but was not rejected.

The emitter now explicitly rejects logical/mixed logical array literals.
No tagged-array representation is added. New target-paired regressions cover
all-logical, integer/logical mixed, and unreachable logical-array literals,
including the exact experimental rejection reason. Ordinary fixed I64 arrays
remain covered by both array workloads and error fixtures. This is a boundary
correction, not support for dynamic or logical arrays.

Fresh result: run.sh 40 PASS lines, 5089 differential calls and 20 exact
error comparisons pass. Rebuilt normal-backend battery: 1086 PASS, zero
failures. These checks use Linux and PE under Wine, not native Windows.

## Scalar sequence increment, 29 October 2026

Parenthesized comma expressions now evaluate all children left to right and
return the last value within the existing I64/logical slice. Prefix effects
are never removed by literal-result folding. The last expression determines
logical-output rejection and existing integer print provenance, so a logical
sequence cannot silently print as integer and a large final literal keeps
its established field width. No float, owned, tagged or NIL value support
is added; every child passes the existing lowering checks.

`sequence.hb` checks increment/call order, use as a function argument,
short-circuited sequences, WHILE-test effects, indexed reads and value-before-
index writes, nested sequences, and a large final integer literal. The full
output bytes match the current backend, with 25 independent expected integer
observations. `error-sequence.hb` checks exact callstack/exit/output on a
failing middle expression, including that later effects do not execute.
Logical-output and floating-result sequences retain explicit rejection tests.
This adds evaluation support, not a performance or Rust-quality claim.

Fresh result: run.sh 45 PASS lines, 5089 function comparisons and eleven
controlled-error fixtures on two targets (22 exact diagnostic comparisons).
Rebuilt default-backend battery 1086 PASS, zero failures. Linux and PE/Wine
only, on the same 28 October host/toolchain; no native-Windows measurement.

## Existing-source regression integration, 29 October 2026

The LLVM local collector now includes the implicit counter introduced by FOR,
matching the checked frontend/current backend. Existing t42/t48/t49/t129 sources
previously failed experimental emission with `unknown local` unless a redundant
LOCAL declaration was added. No source edits or frontend changes are required.

`check_regressions.py` builds seven existing tests unchanged through both
backends on Linux and PE/Wine: t28/t42/t48/t49 loop control, t129 array fill,
and original-source t907 (while.prg) / t997 (recursiv.prg) fixtures already
preserved in tests/. Each execution must match the frozen manifest bytes,
exit0 and empty stderr, not merely agree with the other backend. The sources
remain untouched. This checks 28 executions across seven sources, two backends
and two targets. It is not a new sweep of all 175 originals or a new compatibility
count: the broader frozen-corpus status is unchanged/unrechecked by this step.

Fresh full run.sh result: 59 PASS lines, 5089 function comparisons and 22 exact
diagnostic comparisons. No performance, executable-size or broad Rust claim.

## I64 Min/Max increment, 29 October 2026

Min/Max on two I64 operands now evaluates both arguments left to right and
selects using signed <=/>=, choosing the first on ties. The existing frontend
arity/type checks remain. Logical and float variants stay outside the LLVM
slice and are rejected; no new representation or runtime helper is added.
The current backend's matching-type rules and first-on-tie signed comparison
establish the semantics; the broader existing t1066/t1067 regressions include
variants (byref/float/logical) not admitted by this increment.

minmax.hb covers signed extremes, ties, nested calls, prefix/sequence effects,
argument-call order, and large literal print provenance. Complete bytes match
the current backend on Linux and PE under Wine, with 22 independent expected
integer observations. error-minmax.hb checks that the first argument's effect
precedes a failing second-argument index, including exact diagnostic bytes.
There are no new speed, size or Rust-comparison claims.

Fresh result: full run.sh 64 PASS lines, 5089 function comparisons, twelve
controlled-error fixtures on two targets (24 exact diagnostics), and seven
unchanged-source regressions on both backends/targets. Rebuilt normal-backend
battery 1086 PASS, zero FAIL. Windows validation remains PE under Wine only.

## I64 bit-operation increment, 29 October 2026

hb_bitAnd/hb_bitOr/hb_bitXor/hb_bitNot now lower to I64 bit operations,
with all arguments evaluated left to right. hb_bitSet/hb_bitReset/hb_bitTest
support only the existing frontend's literal bit-index range 0..63. Masks
use unsigned construction, including bit63, without undefined signed shifts.
BitTest is tracked as logical so direct or local logical output remains a
named rejection; it works in conditions/IIF inside the existing slice.
No dynamic indices, float conversion, new value representation or ABI helper
is introduced. Existing frontend restrictions and default codegen are unchanged.

bitops.hb checks negative operands, bit63, variadic evaluation effects,
nested operations, conditionals/short-circuiting and sequence operands. Full
output matches the normal backend on Linux and PE/Wine, with 29 independently
expected integers. error-bitops.hb checks an error in the second of three
arguments, preserving the first effect and suppressing the third. Regression
rejections cover BitTest output (direct/local), dynamic/out-of-range indices
and float operands. No new performance or Rust-quality claim follows.

Fresh result: full run.sh 72 PASS lines, 5089 function comparisons and thirteen
error fixtures on two targets (26 exact diagnostic comparisons). Rebuilt normal
battery: 1086 PASS, zero FAIL. No native-Windows result is claimed.

## Admitted-source Linux audit, 29 October 2026

`python3 experiments/llvm-scalar/check_regressions.py --scan-supported-linux`
selects existing tests/ successful-output (`pos`) manifest sources admitted
by the experimental emitter, then builds/runs each on Linux through both
backends against frozen expected bytes. The audit currently admits 126
sources and all 252 executions pass. This includes preprocessor paths,
Unicode output, arrays, control flow and original-source fixtures without
editing their source. Includes use -I tests, and expected escape decoding
uses printf %b to preserve UTF8. Generated inputs, rejected sources and
non-pos manifest kinds are outside this audit. A rejection is not counted
as a runtime pass. No inference is made about the full compatibility corpus,
Windows support for those 126 sources, or native-Windows behavior. The regular
seven-source paired-target regression subset remains in the normal run.sh.
This is a bounded correctness audit, not a benchmark or broader language claim.

## Admitted failure-source Linux audit, 29 October 2026

The same harness accepts --scan-errors-linux for existing posx sources. Seven
are admitted: t133/t142/t143 bounds and t888/t903/t904/t905 increment overflow.
All fourteen Linux executions match their required exit1, empty stderr and
manifest expectation under the original shell runner's trailing-newline
normalization. In addition, complete stdout bytes must agree between the two
backends, including final newlines and diagnostic callstack. This distinction
is explicit because some posx manifest rows omit a final newline while the
runtime prints one. Successful pos sources continue to require exact manifest
bytes. No source/expected output was changed to make the audit pass.
This is Linux-only and covers admitted failure cases, not every error or the
full language battery. All seven pass; no new production defect was found.

## Scalar/fixed-array Empty increment, 29 October 2026

Empty() now accepts the already-lowered I64/logical expressions and variables
of fixed I64 arrays. Zero/false are empty; a nonempty fixed array is not empty,
even if its elements are zero. Its logical result is tracked through locals
and sequences; logical output remains rejected. String, NIL, float and dynamic
collection operands remain unsupported. No representation or helper is added.

empty.hb checks signed limits, scalar/logical values, all-zero nonempty arrays,
indexed elements, call/increment/sequence effects and short-circuited logical
operands, with exact backend output and 20 independent expected integers.
error-empty.hb checks exact diagnostic bytes on an invalid element operand.
Direct/local output and string/NIL operands have explicit rejection tests.
This is scoped builtin support, not a speed/size or broad Rust-quality claim.

Fresh result: run.sh 79 PASS lines, 5089 function comparisons and fourteen
error fixtures on two targets (28 exact diagnostics). Rebuilt normal-backend
battery 1086 PASS, zero FAIL. Linux and PE/Wine only, not native Windows.

## Cross-feature correctness interaction, 29 October 2026

interaction.hb combines fixed-array updates, signed Min/Max, bit operations,
Empty, short-circuit conditions, sequences, LOOP/EXIT and a final bounds-guarded
WHILE across 33 signed inputs. An independent Python state-machine oracle checks
the full resulting integers in addition to exact current/LLVM output on Linux
and Wine. This is an untimed correctness case designed to exercise feature
interactions; it is not another performance kernel or a general language claim.
No production code changed. Full suite now reports 82 PASS lines with previous
5089 function comparisons and 28 exact diagnostic comparisons unchanged.

## Existing logical scalar signatures, 29 October 2026

The emitter now accepts frontend-checked Bool parameters/returns as well as
I64. The physical lowering remains i64 arguments/return and 8-byte local
slots containing 0/1, as already used for local logical expressions; no tagged
representation, ownership rule or external adapter contract changes. Signature
metadata now marks logical parameters and return-call expressions, including
assignments/IIF/sequences, so they cannot bypass logical-output rejection.
No inferred integer/logical coercion is added. Byref remains unsupported.

boolcalls.hb checks argument/return propagation, nested calls, self recursion,
mutual recursion and short-circuited calls with effects, with 37 independent
expected integers and exact normal/LLVM bytes on both targets. Existing
`t601_shortcircuit.hb` now runs unchanged against its frozen expected output
on Linux and Wine (eight unchanged-source regressions in the regular suite).
error-boolcalls.hb checks the complete callstack across logical call frames.
Direct returned-logical output, logical parameter output, local copies of
logical returns and logical byref retain explicit rejection fixtures. Existing
t602 output remains outside the slice: adding signatures does not add logical
printing. This is scoped type propagation, not a general Rust-quality claim.

Fresh result: full run.sh 91 PASS lines, 5089 previous function comparisons,
fifteen error fixtures on two targets (30 exact diagnostic comparisons), and
eight unchanged-source paired-target regressions. Rebuilt default battery:
1086 PASS, zero FAIL. Windows means PE under Wine, not native Windows.

## Logical-call ABI and boundary follow-up, 29 October 2026

The existing register/stack canary now calls ll_boolflip with both0 and1,
checking the opposite0/1 return before validating callee-saved registers,
stack pointer and trace-chain restoration on Linux and PE/Wine. This directly
checks the logical scalar signature's unchanged physical calling convention,
in addition to recursive/end-to-end logical-call tests. No adapter was added.
New rejections cover Min with logical-return calls, sequence printing of a
logical return and an integer passed to a logical parameter. A focused audit
also confirmed the frontend rejects logical-call array literals and logical
writes to fixed I64 arrays. No new production defect was found by this follow-up.

## Logical output through the existing string adapter, 29 October 2026

Logical QOut/QQOut items now select a pointer to the three-byte literal .T.
or .F. and use the existing rt_str/hbc_print_str adapter. No helper, physical
ABI, tagged value or ownership change is introduced. All arguments still
execute before the outer print starts; separators/newlines and final literal
string trimming retain the current backend's behavior. Prior logical-output
rejection fixtures were removed because that feature is now explicitly admitted.

booloutput.hb covers logical locals/branches/IIF/sequences/returned values,
BitTest/Empty, ordered nested printing, short-circuited effects, QQOut joining,
and mixed literal/string spacing. A full independent byte oracle checks these
spaces/tokens, in addition to current-vs-LLVM parity. error-booloutput.hb
confirms an error while evaluating a later item prevents the outer newline or
earlier logical item from printing. Existing t602/t606/t722 now pass unchanged
against manifest bytes on Linux and Wine; eleven existing sources are checked
in the regular target-paired regression subset. Logical arrays/dynamic types
remain rejected. No speed, size or general Rust-quality claim is added.

Fresh result: run.sh 93 PASS lines (ten obsolete rejection lines removed,
nine new success/oracle lines added), 5089 previous function comparisons,
sixteen error fixtures on two targets (32 exact diagnostics). Rebuilt normal
battery 1086 PASS, zero FAIL. Counts are actual runner lines, not language
coverage percentages. Windows remains PE under Wine, not native Windows.

## Matching logical Min/Max, 29 October 2026

Min/Max now also admits matching logical operands using the existing0/1 scalar
representation and signed selection, with both arguments evaluated left to
right. Result classification follows the first operand's checked type. The
frontend still rejects mixed logical/integer inputs and floats remain outside
the emitter. No coercion, representation or ABI change is introduced.

boolminmax.hb checks the complete two-input truth table, nested results and
locals, Empty/NOT/conditions, and both argument effects even when the first
would determine the result. Independent expected bytes and current-backend
comparison cover Linux and PE/Wine. Two former rejection fixtures are removed
because this matching-logical form is now admitted; full run.sh has94PASS
lines,5089 prior comparisons and32 exact diagnostics. No performance claim.

## Disjoint logical-local scope correction, 29 October 2026

A targeted scope audit found wrong experimental output when disjoint IF arms
reuse a local name with different types: a Bool local in the first lowered
arm left its classification behind, causing the integer local in the other
arm to print .T. instead of7. The frontend correctly allows those disjoint
locals, and the default backend prints7. This is a confirmed output defect,
not merely a rejected program or hypothetical concern.

Logical classification is now saved/restored at statement-block boundaries.
Each arm/nested body starts from the enclosing classifications; block-local
names cannot contaminate sibling arms. The frontend's fixed outer-variable
types and existing physical slots are unchanged. boolscope.hb checks both
runtime arms, both Bool/I64 declaration orders, enclosing logical locals and
nested disjoint locals, against independent full bytes and current-backend
output on Linux and Wine. No checker, representation, ownership or ABI change.

## Post-scope array boundary check, 29 October 2026

The adjacent array/scalar name case is a registered experimental limitation:
disjoint arms that reuse an array name with different lengths, or reuse the
name for a scalar, are rejected by the current name-keyed slot collection.
No wrong execution was observed for these cases because emission fails.
Two paired-target rejection regressions preserve that boundary. This follow-up
does not implement a new scoped storage model or claim those valid default-
backend programs are supported by LLVM.

The existing-source audit was re-run after the logical/scope increments:
134 admitted successful-output test sources (268 Linux executions across two
backends) and seven admitted failure sources (14 Linux executions) pass their
registered checks. This supersedes the earlier126/127 admitted-success counts
for this branch state only. It does not count rejected programs, rerun the175
original corpus, or establish those134 cases on Windows. No benchmark added.

## Separate correctness from timing, 29 October 2026

Routine run.sh no longer reruns the three historical timing series. It still
builds/runs differential validation, output/error comparisons, independent
oracles, unchanged-source regressions and ABI canaries. Set RUN_BENCHMARKS=1
to explicitly build/run the traced, untraced and traced-Rust measurement
harnesses with the previous method. A correctness-only run removes their
ignored run/*.csv samples to avoid leaving stale samples mistaken for fresh
ones. Published historical results/ files are untouched. This is a test-process
change, not a performance improvement or language expansion.

## Signed-I64 extreme-value correctness, 29 October 2026

integeredges.hb checks eight signed operand pairs including min/max I64,
-1/0/1 and +/-2^32. An independent arbitrary-precision Python oracle reduces
+/-/* modulo2^64 back to signed I64 and checks six signed comparisons,
Min/Max and XOR. The independent oracle compares value/logical tokens, while
complete output bytes still match current-vs-LLVM. It does not invent a new
numeric print-width oracle. This validates the existing wrapping-I64 contract,
not Harbour's broader numeric promotion or a benchmark. No production change.

## Declaration slots and lexical bindings, 29 October 2026

The previous name-keyed whole-function prescan rejected valid disjoint locals
with different fixed-array lengths or scalar/array types. The emitter now
allocates a unique physical slot per LOCAL declaration while saving/restoring
name bindings at block boundaries, matching the checked/default lexical scope.
Allocas accumulate in function entry, not inside repeated bodies; initializer
effects remain at the declaration's original position. Parameters retain their
existing slots. FOR reuses a visible I64 counter or binds an implicit counter
only for the loop, preserving START/store/END order and overflow termination.

Representation remains i64/0-or-1 scalar slots and [k x i64] fixed arrays.
There is no storage union, aliasing/copy rule, tagged array, ownership or ABI
change. The frontend/default are untouched. Block restoration also runs on
terminated/error lowering results; dead-tail probes still discard their IR
and allocations. Existing array reassignment writes remain sequential rather
than acquiring invented temporary-copy semantics.

scopedslots.hb covers both disjoint-array lengths, scalar/array names in both
orders, Bool/scalar names, repeated declarations, nested WHILE/IF, reused and
implicit FOR counters, initializer call order and dependent reassignment.
Independent bytes and current/LLVM output match on Linux and PE/Wine.
error-scopedslots.hb checks exact origin/callstack for a scoped-array bounds
failure. Unsupported scoped strings behind EXIT still reject. The old two
rejection fixtures now correspond to explicitly admitted valid programs and
are replaced by success coverage. Entry-only alloca placement was inspected
in generated scopedslots/boolscope/loopcontrol IR.

Fresh local full suite:104PASS lines,5089 prior function comparisons and
seventeen error fixtures on two targets (34 exact diagnostics). Existing
Linux audits134pos/7posx pass, and rebuilt default battery1086PASS,zeroFAIL.
These are bounded correctness results, not a benchmark or full compatibility
claim. Native Windows is not tested. The former disjoint-array limit above is
historical and superseded by this increment, not silently removed.

## Original fornext and mention-clean bare counter, 29 October 2026

Bare LOCAL (NIL initializer) now lowers to an I64 zero-initialized slot ONLY
when the existing shared bare_local_is_for_counter predicate proves the same-
block first mention is a FOR counter with mention-free bounds. This exactly
matches the frontend/default special case. It is not general NIL/Dyn support:
observed-before-loop, self-referencing bounds and nested-first-use remain
rejected. A normal declaration binding is created at its original site.

fornext-original.prg is unchanged upstream harbour/core 694428e1's fornext.prg,
SHA256 7df8bbea5c9daacfe9d8a439ab2d4ebce3417ce4b15628276819b451cc6aa585,
also identical to the preserved sondas/hk339.prg. Its 337-byte output matches
an independent expected loop sequence and the historical hk339 record, as
well as current-vs-LLVM exact output on Linux and PE/Wine. No fresh Harbour
binary/oracle was built in this increment; that historical reference is stated
rather than claimed as a new Harbour run. Existing t792 now passes unchanged
in the paired-target manifest regression subset. Source originals are not edited.
This establishes this original's execution, not runtime success for all 175.

The barecounter fixture checks bound effects, zero-trip counter value, disjoint
block slots and scope restoration. The full local run has 119 PASS lines;
the rebuilt default battery has 1086 PASS lines and ALL GREEN. These are
correctness results only, not a new performance comparison.

## Discarded output effects, 29 October 2026

A separate effect lowering path handles CallStmt and discarded sequence prefixes.
QOut/QQOut reuse the existing checked print_items path; IIF evaluates only its
selected arm, and discarded literal NIL emits nothing. No scalar sentinel is
created for NIL. Value-position output/NIL still rejects, as do stored NIL/Dyn
and OutStd/OutErr. Unsupported dead arms and statements after a terminator are
still inspected before admission. Frontend type/ownership rules are unchanged.

The discardeffects fixture checks output-before-outer-newline order, output
argument order, lazy chosen/dead arms, NIL no-op arms, nested numeric IIF and
comma-sequence effects, against explicit bytes and the default backend. Full
suite: 129 PASS lines on Linux and PE/Wine. This does not yet admit the unchanged
ifinline original: its scalar-versus-NIL comparison remains outside this step.
No new Harbour run or performance claim is made.

## Literal NIL versus checked scalar equality, 29 October 2026

Exactly one literal NIL under =, #/!=, or == now compares with an operand
that must lower through the existing I64/logical expression path. The scalar
operand still evaluates once, including increments, calls, output prefixes and
bounds checks. The equality result is a constant logical value, not a NIL
representation: distinct categories are false under =/==, true under !=.
The frontend remains authoritative: Bool == NIL and ordering literal NIL
still reject. Strings, arrays, NIL/NIL, output-call results and stored Dyn
remain outside this LLVM change. Neither checker nor runtime/ABI is changed.

The unchanged t982_original_ifinline.hb now runs on Linux and PE/Wine against
its existing manifest bytes and default-backend output. Its SHA256 is
cef71077a08117c32e49ec468be7f38a5ca5817aa2a6175136ba4ed5cf3afa08, identical
to upstream harbour/core 694428e1 tests/ifinline.prg. The existing 64ak Harbour
comparison is historical, not a new Harbour execution. Existing t980 also
runs unchanged. The nilcompare fixture pins exact output/effect order; two
error fixtures verify that bound failures survive folding, in both orders.

Full suite: 141 PASS lines, plus 19 error fixtures checked on each target
against exact default diagnostics (38 paired-target error checks). Default
battery rebuilt: 1086 PASS and ALL GREEN. These counts are separate; no claim
of runtime success for all 175 originals or general performance is made.

## Print-only static literal IIF selection, 29 October 2026

Only print_items admits IIF(cond, literal-string, literal-string). It evaluates
the checked condition once while collecting all item values, BEFORE any outer
newline or separators, then selects pointers and lengths of private constants.
The existing rt_str ABI prints that pair. Both arms are static literals, with
no effects, heap ownership or temporary-string lifetime to transfer. When this
is the last item, space byte 0x20 is trimmed from each constant in advance,
matching default runtime right-trim. Interior trailing spaces are preserved.
No string local, string return ABI, general string expression or stored result
is admitted. Variable arms and nested string IIF remain rejected.

exit-original.prg is unchanged upstream harbour/core 694428e1 tests/exit.prg,
SHA256 a14961def1156ec029d6c93bfbda7ce05b9ee5900f842e42843046bff1a9163d.
It is also byte-identical to sondas/hk323.prg and tests/t777_for_reuse.hb.
Linux and PE/Wine output matches explicit expected bytes, the manifest and
the default backend. The documented 63ze Harbour comparison is historical,
not a fresh Harbour execution. printchoice checks effect order, both choices,
empty/all-space literals, interior spaces and nested output contexts.

Full correctness suite: 149 PASS lines. Rebuilt default battery: 1086 PASS,
ALL GREEN. No general string support, fresh Harbour run or speed claim.

## NIL-only internal effect functions, 29 October 2026

Authorized scope: specialize internal calls whose result is always discarded,
without adding general Dyn/NIL values. The frontend remains unchanged: a bare
RETURN / RETURN NIL still gives helpers a Dyn return type. LLVM now proves
structurally that each candidate has no value return (including dead code),
only known statement forms, and no normal path falling out without an explicit
NIL return. Candidates cannot be main and still require I64/Bool parameters.
Loops are conservatively assumed to fall through; both IF arms must terminate
before an IF can establish termination. Unknown constructs reject.

A whole-AST expression-use pass inspects dead arms and post-terminator code.
A candidate call is legal only in discarded effect context. Arguments, print
items, conditions, assignments, value returns and value-producing sequence
positions cannot use its result. Discard context propagates through IIF arms
and sequence prefixes only. The existing frontend may reject some such effect
contexts first; its limits are preserved, not bypassed. Unsupported statement
forms reject in this pass as well as in lowering.

Only these proven helpers use the new internal void/call-void ABI. No dummy
I64 result stands for NIL; expr rejects candidate calls as values. Trace frames
unlink before every ret void. No frontend inference, tagged pair, string/array
ownership, main entry ABI or runtime helper ABI changes. Function pointers and
exports are not part of this slice. Recursive/mutually recursive discarded
calls preserve the same rules.

Unchanged originals from harbour/core 694428e1:
- returns.prg SHA256 52d62274849940932670b12d7929f63e88e87432437a5b5a2f7f181eb6319758
- ifelse.prg SHA256 3514e2804a8090bfe025af3e036294fdd8afafdf8554ededb3bcb888b1f03836
- statfun.prg SHA256 febada350286c04c874b1b3777aa3d1a4523645cdd06d71f5ec207c7a9129d71

The run checks their full output against explicit expected bytes and the default
backend on Linux and PE/Wine. Historical Harbour evidence exists for statfun
(63n) and ifelse (hk333 record); returns is checked against its source-defined
control path and default, not claimed as a fresh Harbour comparison. No new
Harbour compiler was built or run in this increment.

Tests cover recursion/mutual recursion, early returns in loops, three error
fixtures (inside recursive helpers, after return to caller, and in arguments),
result uses including unreachable code, and rejection of mixed/value returns,
Dyn parameters and unsupported candidate constructs. Direct ABI canaries call
void helpers with integer and logical inputs, check preserved registers/stack
and restored trace top on Linux and PE/Wine. An IR-shape check pins void calls
and trace unlink at every return. Full suite: 175 PASS lines; error fixture
checks are separate (22 fixtures x2 targets). Default battery: 1086 PASS and
ALL GREEN, rebuilt after the production changes. No new performance claim.

## Borrowed local constants and raw OutStd, 29 October 2026

Authorized scope: local strings borrowed from constants, no escape/general
memory management, and OutStd for unchanged longstr. LLVM holds a lexical
binding to immutable constant bytes, not a string local slot or an owned value.
Only LOCAL initialized by a pure tree of string literals, concatenation of
such trees, and Chr(integer literal 0..127) qualifies. The Chr restriction
matches the existing low-byte helper for ASCII/NUL and deliberately rejects
higher bytes, negative, dynamic and non-literal arguments instead of inventing
a Unicode conversion. Frontend types are unchanged, even when the frontend
calls a pure concatenation StrOwn. The backend computes those pure bytes once;
no calls, variable reads, side effects or runtime error conditions are folded.
This removes default-backend allocations for these constants; it is not a
claim about allocation-counter equivalence or general memory exhaustion.

Borrowed bindings may only be direct print/output items. Copy, reassignment,
return, arguments to user functions, address/byref, capture, comparisons and
other value uses remain rejected, including dead code. Bindings restore at
lexical block boundaries. Existing source ownership checks remain active.
There is no string parameter/return ABI, heap helper or runtime mutation.

OutStd in discarded effect context reuses print_items and rt_str: evaluate all
items first, no leading newline, preserve all trailing spaces, and insert one
separator between arguments. Zero items emit nothing. QOut/QQOut keep their
existing trim behavior. hb_eol is admitted only as a direct output item and
uses LF on Linux, CRLF on Windows. OutStd results remain unavailable as values;
OutErr, Dyn and unsupported arrays/strings remain rejected.

longstr-original.prg and simpleio.ch are unchanged from the pinned upstream.
The source SHA256 is ccc83f05e2f8f0aa89dc2f90807586c9cbf584066a41177dd7457d9f914bbdb1,
identical to existing t1041. Its Linux 502-byte and Windows 503-byte outputs
match the existing binary expectations AND the respective default backend.
Windows comparisons run the Windows default binary under Wine, not a newline-
normalized Linux result. Historical 64as Linux Harbour oracle is reused; no
fresh Harbour run and no live Windows Harbour oracle are claimed.

borrowedstrings covers lexical bindings, pure Chr/NUL, raw trailing bytes,
QOut/QQOut trim, lazy output, argument effects and platform-native hb_eol.
A raw-output error fixture ensures no prefix is printed before a later item
fails. Boundary negatives cover dynamic/high Chr, effectful trees, escaping,
copy/reassignment/capture, return and value-position OutStd, including dead
uses. Full suite: 191 PASS lines and 23 error fixtures x2 targets (separate
from PASS count). Default rebuilt battery: 1086 PASS, ALL GREEN. No new speed
or size claim. main and the frontend/default backend remain untouched.


## Trace-global binding and target relocation, 29 October 2026

The experimental freestanding executable links the generated runtime object,
which defines `hbc_trace_top`, into the same executable. Its LLVM declaration now
says `external dso_local global ptr`. This expresses the existing linkage, not
a new shared-library runtime contract. It permits direct access rather than a
GOT address kept in a callee-saved register. Trace entry, statement writes,
restoration, overflow and bounds checks are unchanged. A future DSO runtime must
revisit this declaration; dynamic interposition is not supported by this slice.

The AOT driver's formerly opaque relocation value 2 means PIC, not static.
The initial method description above was wrong; the later PE note was correct.
Linux now uses named Static=1 with Small=3; Windows retains PIC=2 because static
string addresses overflow ADDR32 at the current 64-bit PE base. The failed local
static-Windows build is not counted as a pass. Enum source (release/23.x):
https://raw.githubusercontent.com/llvm/llvm-project/release/23.x/llvm/include/llvm-c/TargetMachine.h
Binding semantics: https://llvm.org/docs/LangRef.html#runtime-preemption-specifiers

One fresh x86-64/Linux harness with equivalent manually instrumented Rust trace
writes, the same checks, O3/baseline CPU and linked runtime gives these function
sizes in bytes. This is machine-code size, not instruction count or whole-file
size:

| Kernel | Previous LLVM (PIC) | New LLVM | Rust control |
|---|---:|---:|---:|
| sum | 223 | 212 | 212 |
| branch | 317 | 304 | 304 |
| factorial | 114 | 113 | 113 |
| recurrence | 220 | 216 | 225 |
| array16 | 817 | 843 | 843 |
| array256 | 3470 | 3455 | 3439 |

The new factorial removes the extra saved register/address materialization.
Three 31-sample runs pinned to CPU0 had LLVM/Rust median-time ratios of
0.980/1.007/0.993 for factorial and 0.747/0.750/0.999 for sum. Other kernels still
show layout/host variability. This is evidence for these six kernels, not
language-wide speed parity or a stable speedup percentage. The relocation and
binding changes can trade code size in either direction (array16 grows).
Raw samples, sizes, assembly, environment and validation logs are saved under
`results/trace-binding-20261029/`. Previous comparisons used PIC LLVM, despite the
old initial documentation calling it static; they must not be called
static-vs-static evidence.

Validation after this change: 192 PASS runner rows on Linux and cross-generated
PE/Wine, 5089 differential calls, ABI/trace-restoration canaries, plus 23 error
fixtures on both targets (46 exact stdout/exit/callstack comparisons, reported
separately). A freshly rebuilt default backend passed 1086 manifest rows and
ended ALL GREEN. The new linkage guard checks direct non-GOT trace-global
relocations on ELF and absence of absolute ADDR32 string relocations on PE.


## Routine correctness check against traced Rust, 29 October 2026

The regular runner now builds the existing equivalent traced Rust controls
without taking timing samples. It compares both default and LLVM kernels to
Rust across n=-12..1000, plus factorial n=-3..40 (wrapping multiplication).
All 10218 backend/Rust result comparisons pass, and the trace chain is null
after every batch. Existing 5089 default/LLVM comparisons remain separate.
This extends result checks for these kernels; the Rust control is manual,
not a proof of compiler correctness or general performance parity.

Assembler review of the latest Linux comparison: sum has 35 instructions in
each backend, factorial 23, branch 53. Sum/factorial operations match apart from
addresses and the recursive call target; branch has a different block layout.
This is additional reason not to interpret the observed faster sum timings as
a stable advantage over Rust. Recurrence and arrays still differ structurally.

## Expanded speed controls and rebuilt Harbour oracle, 29 October 2026

Five added kernels use only the already admitted I64/control-flow slice:
bit operations, Min/Max, a helper in a loop, reverse FOR, and WHILE with
LOOP/EXIT. The routine runner checks exact output on Linux/PE-Wine and 10130
additional backend/Rust result comparisons, separately from the earlier
10218 and 5089 checks. It does not take timings unless RUN_BENCHMARKS=1.
Current full run: 194 PASS rows; 46 exact error comparisons remain separate.

Three 31-sample CPU0 series, n=1M, equivalent manual Rust trace points,
LLVM/Rust median-time ratios: bits0.866-0.867, Min/Max0.997-1.001,
helper calls0.996-0.999, reverse1.196-1.198, WHILE0.999-1.006.
Reverse is an open performance investigation, not a corrected regression.
The versions/layouts of LLVM differ; fewer instructions alone do not win.

A Harbour reference was freshly built locally from the pinned official source
694428e1c12f726675b19324d62167fa77d68185, GCC -O3, no contrib. Source is only
an oracle and is not copied into this MIT implementation. The opt-in scripts
under bounded-comparison/ require HBMK2 explicitly, generate their own test
sources from scratch and never install or download the reference. They are
not run by the routine battery.

The new full-process comparison uses 2M iterations and bounded integer values:
reset accumulation, masked bit recurrence and masked reverse recurrence. No
intermediate magnitude reaches 6M, so the old i64-wrap versus Harbour-double
problem does not arise. All five outputs are byte-identical before timing.
Rust starts from black_box input to prevent full constant evaluation. These
are normal configurations (Harbour diagnostic settings, HarbourRust native
traces, plain optimized Rust), not matched diagnostic overhead. The earlier
trace-equivalent kernel series remains the fairer diagnosis of codegen cost.

Median milliseconds from each of three independent series (7 samples after
2 warmups per program/config/series, rotating order, CPU0, Linux):

| Workload | Harbour pcode | Harbour -gc3 | HR default | HR LLVM | Rust |
|---|---|---|---|---|---|
| Reset sum | 200.727 / 196.652 / 193.734 | 119.961 / 120.578 / 118.908 | 12.962 / 12.986 / 13.150 | 5.884 / 5.750 / 5.755 | 4.729 / 4.538 / 4.519 |
| Masked bits | 236.178 / 240.964 / 236.049 | 192.422 / 194.649 / 191.594 | 22.481 / 22.475 / 22.439 | 4.501 / 4.448 / 4.447 | 5.193 / 5.261 / 5.203 |
| Masked reverse | 159.253 / 158.611 / 158.641 | 128.147 / 128.634 / 128.639 | 13.929 / 13.814 / 13.797 | 2.745 / 2.548 / 2.612 | 3.272 / 3.232 / 3.242 |

These include process/taskset/startup/output time, not just the loop. Do not
extend them to strings, objects, RDDs, all programs, or Windows. The masked
reverse is different work from the wrapping reverse above; it does not close
that deficit. Whole-file and stripped bytes plus GNU size summaries are in
results/expanded-speed-20261029/whole-file-sizes.json, not function-byte claims.
Harbour links its runtime; Rust links std/CRT; HR is freestanding. Tiny file
size here is not a controlled runtime-equivalent codegen advantage.

Raw CSV, environment, symbol sizes, assembler and validation logs are under
results/expanded-speed-20261029/. Build paths are recorded for evidence only;
use the portable scripts with explicit HBMK2 for reproduction. The default
1086-row battery was last rebuilt and passed at77f972a; these additions change
only tests/docs, not production lowering, and do not claim a new default run.

## Diagnostic text interning (2026-10-29)

The experimental emitter now reuses identical immutable diagnostic text bytes.
Every volatile pointer/length update is preserved, including repeated updates
on the same source line. No new value representation, ownership rule or runtime
helper/trace ABI is introduced. Trace text pointers are only consumed as bytes
by the existing formatter; no pointer-identity promise is made. No `unnamed_addr`
assumption is added: the emitter simply refers to one private constant for the
same text. General program strings and production trace enablement are unchanged.

The paired IR guard compares decoded constant byte sequences at every volatile
text/length store and trace-chain operations before/after. Fresh full suites:
default1086PASS, LLVM194PASS on Linux/PE-Wine, plus10218/10130 Rust control
comparisons and46 separate exact failure checks. This is correctness evidence,
not Windows-native validation or a language completion claim.

Same-basename, same-driver object sizes (file bytes / GNU text including constants):
perfextra9496/4619 ->9192/4315; corpus8112/3678 ->7856/3422;
arraywork8336/5761 ->8224/5649. Sized function symbols remain separate in the
versioned result. These are object-size savings, not whole-binary Rust parity.

Fresh traced inverse medians after the change were0.9932-1.0005 LLVM/Rust,
untraced1.0005-1.0015. Host/layout variability remains; do not attribute the
previous ~20% observation to duplicated constants or claim a durable speed fix.
The reproducible inverse control and before/after guard are opt-in tools, not
timing gates in the routine battery. Shared src/pp.rs is untouched.

The routine suite now includes12 compile-only trace interning canaries (6 sources,
both Linux/Windows). A frozen source hash and byte/length update-sequence hash
protect against silently dropping repeated updates; unique constant references,
lengths and all volatile pointer-store counts are checked separately. This adds
no timing work and does not turn compile-only checks into runtime coverage.

# Experimental LLVM scalar AOT gate

This branch is a feasibility test, not a replacement backend. Default `hbc`
behavior is unchanged. `--experimental-llvm` uses the same preprocessor, parser
and semantic/ownership checks, then emits LLVM IR for a deliberately small
scalar subset. LLVM verifies, optimizes and emits an object, linked with the
existing assembly runtime through target-C-ABI adapters. No JIT, VM or new
ownership/collection representation is introduced.

## Status and boundaries

Current supported slice: I64 function signatures/locals, integer + - *,
signed comparisons, logical .AND./.OR./.NOT. with short-circuit evaluation,
IF, WHILE, EXIT/LOOP, FOR with its existing signed-overflow termination, user calls and
recursion, left-to-right scalar sequences, lazy IIF, integer and literal-string output, ProcLine current-frame
or literal0, and fixed I64 stack-array literals/index reads/writes/len.
Arithmetic uses wrapping LLVM operations, without invented nsw/nuw promises.
Native three-word trace frames preserve the tested diagnostic paths. See the
dated follow-ups below for the evidence and historical configurations.

Still rejected: dynamic values, floats, owned strings, byref ABI,
most builtins, logical output, dynamic/growing/nested arrays, array parameters
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
Logical output and logical function signatures remain outside the slice.

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

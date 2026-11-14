# Isolated own ARM64 backend experiment

Base: `e5bf1bb640fb4befcd661e65bb75ba501f3c5ab9` (14 November 2026).

This directory is an engineering increment, not native ARM64 support in hbc.
The production compiler, its host default and its ARM64 rejection are unchanged.
No files under `src/` change. No Mac loader, Apple Silicon hardware, actual
Darwin syscall or Apple signing-policy verdict has been tested here.

## What is implemented

- Own Rust instruction encoder and label fixups. Operand APIs reject x18,
  bad registers, invalid immediates, misalignment, pair/writeback overlaps,
  branches to data, duplicate/unresolved labels and relative-address overflow.
- Own Rust SHA256 and an input-validated Mach-O writer accepting code bytes,
  read-only bytes, an entry offset and a signing identifier. It writes ARM64
  PIE, 16 KiB-aligned segments, dyld/libSystem load commands and an ad hoc
  CodeDirectory signature. It has no relocation/import/writable-data API.
  Input bytes are not disassembled or proven safe by the writer.
- An isolated lowering path from the existing checked AST, with its own
  small scalar console runtime. It does not translate x86 instructions.
  The runtime handles short writes, EINTR, no progress and write failures.
- A separate harness generator copies the frontend and generated DBF source
  to the test directory. Only that copy replaces the early ARM rejection
  and adds the experiment after the existing semantic checks. Source SHA256
  is pinned; a different frontend requires deliberate review/rebase.
- Independent development checks use Python hashlib, a second Python writer,
  a standard-library layout/signature verifier, optional macholib, optional
  LLVM encoding references, and Unicorn with an explicit syscall model.
  None is part of hbc or of output generation.

## Deliberate scalar boundary

The original scalar boundary covered integer/logical literals, locals/copies/assignment,
integer comparisons, logical short-circuiting, IF/WHILE/EXIT/LOOP, scalar
calls with up to eight arguments, discarded nil-only calls, and formatted
output. All output items are evaluated before the QOut newline, as in hbc.
Nonempty literal strings without a trailing space or an embedded CR/LF can
be printed. Local strings are outside this first boundary.

The finite F64 transport follow-up below extends literal/copy/call/compare
handling only; runtime arithmetic still rejects.

Every function and AST branch is visited, including unreachable code. Missing
families reject without writing a new output file. They include runtime
arithmetic (overflow-to-double and integer provenance are not ported), floating
point arithmetic and nonfinite source values, heap/Dyn values, arrays, hashes, objects, by-reference calls, most
builtins, STATIC, TRY/CATCH, FOR, INIT, EXTERNAL, threads, pending-console
spaces/empty strings/multiline strings, assembly output and instrument/LLVM/
external-assembler modes. A frontend-inferred Dyn recursion result also rejects.
Constant arithmetic already folded to an integer by the existing frontend
can pass; this does not mean ARM runtime arithmetic exists.

The harness uses conservative fixed 4080-byte local frames, with a named
frame limit. It is not a production frame allocator. Read-only data references
currently use ADR and reject if its signed relative range is exceeded. The
writer has an explicit 64 MiB payload limit and printable-ASCII identifier
limit of 255 bytes. These are experiment limits, not new production limits.

## Run the checks

Use stable Rust and Python 3. Copy this directory outside the checkout first:

```sh
work="$(mktemp -d)"
cp -R experiments/arm64-native/. "$work/"
python3 -m venv "$work/venv"
"$work/venv/bin/pip" install -r "$work/requirements-dev.txt"
"$work/venv/bin/python" "$work/run-checks.py" --repo "$PWD"
```

`RUSTC` can select the stable compiler. Optional `LLVM_SHARED_LIBRARY` points
to a development LLVM shared library exposing its C API; when set, the runner
also compares 20 instruction encodings byte for byte. LLVM is an oracle only.
`--without-emulator` runs the own writer/signature/unit checks without the
optional Python packages or either full frontend build. The scalar experiment
binary is named `hbc-arm64-research`, never the production `hbc`.

The runner leaves its generated sources, executables and JSON records in the
copied directory. It does not modify the checkout. The production compiler is
also built there as `hbc-baseline` to verify its ARM rejection and to provide
the current Linux stdout oracle. Run the differential emulator battery on a
Linux x86-64 host: the reference outputs are executed there, not on a Mac.

## What the evidence means

The attached review evidence records the exact counts and hashes. Passing
checks mean the measured encodings, emulated computations and mathematical
signature/layout checks agree with their named references. A Linux stdout
comparison is not an independent Harbour VM compatibility claim. A syscall
model is not the Darwin kernel. An emulator is not Apple Silicon. Recognized
Mach-O headers and valid page hashes do not prove dyld accepts or runs an image,
or that Apple's security tools accept it.

Before enabling any native ARM entry point, continue the missing runtime and
language work, review the supported boundary, and test real Mac loading and
execution. No new ARM source program is admitted by production hbc in this
increment. STATIC remains the next separate project priority after ARM work.

## Primary design references

These supply ABI/layout facts, not copied implementation code:

- https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms
- https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-universal-apps-release-notes
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/EXTERNAL_HEADERS/mach-o/loader.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/osfmk/kern/cs_blobs.h
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/dev/arm/systemcalls.c
- https://raw.githubusercontent.com/apple-oss-distributions/xnu/main/bsd/kern/mach_loader.c

## Numeric runtime follow-up

The [isolated numeric building blocks](numeric/README.md) add own arithmetic,
value/format glue and emitted ordinary/mixed decimal formatting probes. They
do not connect runtime arithmetic to this harness's AST or change production
ARM rejection. Error statuses are not yet language exceptions or trace support.


## Isolated value ABI follow-up

`value-abi/README.md` documents the separate pair-call/local, reversible FP
boundary and bounded native trace snapshot probes. These do not change this
scalar harness's arithmetic rejection or add language exception handling.


## Source-mapped native trace follow-up

After base `f35dd50b7f458f71204f3f4e396f756f354ab3c5`, the scalar experiment
adds native stack-local diagnostic records. x19 is its private generated top
pointer: entry preserves the incoming x19, clears the private chain, and
restores it on normal return. Each generated function links its own record and
unlinks it before every return. A separate 48-byte aligned allocation leaves
the established 4080-byte scalar local region (255 slots) unchanged. Records
hold previous/text-pointer/text-length, not a value interpreter stack.

Each checked statement records the frontend's original file/line mapping,
including include-file origins; WHILE refreshes the parent call-site location
on every condition evaluation. The own native trace routine walks linked
records youngest-first without a fixed-depth snapshot array, skips empty
locations and prints the same `Callstack:`/location byte shape as current hbc.
It reuses the own short-write/EINTR/failure writer. Trace-only calls preserve
nonvolatile registers and return normally; panic prints the active chain and
exits 1. The standalone uncaught-zero helper writes the current error message,
then prints the chain and exits 1. This is grounded in the FINALIZED current
x86 output, not merely the pre-finalize helper assembly: finalize_trace routes
uncaught exit-1 tails through hbc_panic_exit. A native Linux zero-divisor fixture
provides an exact full stdout/empty-stderr/exit oracle for a matching raw ARM
fixture, with an original-source path and line.

The normal parent runner now also executes:

- 141 raw native trace/error controls: depths 0,1,4,5,17,65,257, trace return,
  panic and zero-error paths, four full/short/EINTR modes, plus no-progress,
  oversized-return and write-failure cases where output is attempted.
- A checked scalar source fixture observed at all 15 syscall writes: nested
  calls, copied locals, early return, condition re-entry after a loop body,
  caller-chain restoration, and an included line's original path/line.
  Stdout also matches current native Linux hbc. This is scalar AST evidence,
  not evidence that pair-numeric locals/calls are source-admitted.
- Frame boundary controls: 255 scalar locals still run exact and 256 still
  reject without creating output. All 23 new raw/source images pass the own
  structural and signature-hash verifier.
- The existing 35-source cohort in three syscall modes, 22 negative sources,
  three flag rejections and production ARM rejection remain checked.

The new observer hook in the development emulator only lets tests inspect
registers/memory at modeled syscalls. It is not called by generated code.

Still outside this boundary: runtime arithmetic, F64/NumLocal AST arguments,
locals and returns, arbitrary numeric branch merges and print dispatch. The
zero-error helper is tested with raw generated native fixtures; no accepted
source expression calls it yet. No caught exception transport, description
string/ERROR object representation, TRY/CATCH/FINALLY, unwind/cleanup protocol,
PROCNAME/PROCLINE or general dynamic error family has been added. These remain
explicit rejections where applicable. The private x19 convention must be
bridged before any foreign call support. Metadata growth still meets the
existing ADR range and 64 MiB writer limits by rejecting out-of-range images;
no unlimited-depth/size resource guarantee is implied by linked traversal.
All new execution evidence is instruction emulation plus own syscall models,
not a Mac loader, Darwin kernel, Apple hardware or signing-policy verdict.


## Finite F64 source transport follow-up

After base `7ff3014590cf5c195ee01d08c010f935b271f2f8`, the isolated AST
harness accepts a deliberately narrow finite F64 boundary: literals and
already-folded constants within the frontend's existing precision frontier,
fixed-F64 locals/copies/assignments, F64 parameters/returns, like-kind F64
comparisons and ordinary formatted output. This does NOT open runtime numeric
arithmetic. Production hbc is untouched and still rejects ARM targets.

The source checker and signature inference are unchanged. F64 literals use
hbc's existing Harbour decimal parser, not Rust's float parser. Ordinary
literal format is width10/decimal-count; folded floating constants retain the
existing asymmetric10/20 result width. F64 local spills, copies, arguments
and returns transport BOTH payload and format words. Parameters are captured
before any input registers can be overwritten. Arguments are evaluated
left-to-right to16-byte slots before loading outgoing registers. Integer/
logical parameters keep one GPR each and F64 parameters use two, up to eight
GPR words total: the old eight-scalar limit still works, but five F64 parameters
reject. This is a private generated convention, not Apple C aggregate ABI.

Only finite F64 seeds with at most16decimal places are accepted; arithmetic
expressions still reject, including dead code/unused functions. F64 seeds,
copy-only propagation and unchanged fixed signatures make source values finite
throughout this boundary. Mixed I64/F64 comparisons and mixed numeric LOCAL
storage remain named rejections, rather than guessing coercion or dropping
runtime kind metadata. The original frontend's F64 return restrictions remain.
No NumLocal return ABI, numeric branch merge or implicit scalar-promotion ABI
is introduced. Unsupported AST nodes continue to fail before writing output.

Entry saves incoming FPCR/FPSR, normalizes both to zero for F64 comparison/
formatting and restores them on normal return, alongside the scalar native
trace x19 boundary. No TRY/foreign unwind/trap path is claimed. Comparisons
use the ordered ARM floating conditions, with no integer reinterpretation of
payload bits. Ordinary F64 output invokes the already-tested own decimal
composer into a480-byte native frame with a456-byte output buffer, then the
own byte writer. No external numeric formatter is called. Finite binary64
has at most309integer digits; with this source cap of16fractional places plus
sign/point, it fits that buffer. An unexpected composer status fails closed
with experiment-only exit75: this is not a language error or a claim of source
reachability. I/O failure continues to exit74 by existing runtime policy.

Fresh source controls:

-23source programs in three syscall/FP-state modes match current native x86
  stdout exactly: literal widths/decimal provenance, signed zero, copies,
  assignment, fixed-F64 branches, all seven comparisons with loaded operands,
  F64 calls/early returns, nested effects and mixed register arguments.
  Two modes start with nondefault rounding/FTZ/DN and incoming FPSR flags;
  normal returns restore exact state. SP alignment, x18 and nonvolatile
  native GPRs are checked by the emulator.
-11negative sources reject without a new output and preserve an existing
  output canary: arithmetic/zero division, mixed local, precision>16,
  unused/dead arithmetic, unused excessive precision, TRY, mixed comparison
  and five-F64-argument overflow. Numeric-local prescan is per function; the
  earlier-function negative checks that it cannot inherit the last function's
  thread-local semantic state.
-The prior35scalar programs still run exact in three syscall models, including
  eight-scalar/nested-eight-scalar calls. Of the old22negatives, the simple
  F64 literal moves to the positive cohort, leaving21; the dead-after-return
  negative now uses runtime arithmetic rather than an admitted F64 literal.
-The entire native trace/source-origin/frame-limit checks remain in the runner.

These are source transport/formatting measurements, not arithmetic support or
a new Harbour VM oracle. Still no caught exceptions, TRY/CATCH/FINALLY,
cleanup/unwinding, runtime integer overflow at AST level, F64 arithmetic,
NumLocal, numeric C ABI or actual Mac execution. Keep that distinction when
reporting the increment: numeric kernels and source literal transport are
different layers, and their test counts are not compatible-program totals.


## Mixed numeric LOCAL storage follow-up

On base `7695c5d9154438333563e0a90fcad6f94cd0adfe`, the research harness
also accepts mixed numeric LOCAL storage, copies and assignments across
I64/F64 branches. The frontend's per-function numeric prescan selects a mixed
slot before generation, so assigning another numeric kind never changes its
16-byte layout. Runtime copies preserve both payload and format words. A copy
of a mixed local remains mixed even if its immediate declaration expression
looks like one kind. Branch generation retains that stable storage kind; loop
updates use the same slots. Ordinary fixed-type scalar/call rules are unchanged.

Format word 1 remains an integer literal/copy and prints through the existing
integer helper. Floating formats retain their width/decimals and print through
the already-tested own mixed-integral composer, with its explicit FCVTZS bounds.
This preserves the distinct ordinary-F64 versus mixed-local formatting rules,
including integral floating values. Format 0 is computed-integer provenance;
it cannot be created by this copy-only source boundary, and the private print
entry fails closed on it rather than print with incorrect literal width.
That is a reachability claim for this generated entry, not general kernel
support: the separate numeric kernels already use format 0. No runtime arithmetic
expression is admitted, so no new source path produces overflow or zero divide.
The finite-seed/16-decimal print buffer and FP-state contracts remain in force.

Mixed locals cannot be arithmetic/comparison operands in this increment, pass
to calls/by-reference, or return. Original frontend rejections remain where
applicable; the harness rejects other uncovered uses before output creation.
In particular, this is not a new NumLocal return/parameter ABI, numeric coercion
rule, caught error protocol, TRY/CATCH/FINALLY or cleanup/unwinding mechanism.
Inline assignment-expression to mixed storage is not admitted. Those are still
separate steps, not consequences of a working storage slot.

Fresh mixed-storage cohort: 20 programs in three syscall/FP modes exact against
current native x86 output, including I64->F64->I64 and reverse, independent
copies before/after kind changes, both branch arms, loop updates, per-function
same-name locals, signedzero/decimal-width boundaries, integer extrema and
integral-F64 mixed display. 11 negative programs reject with absent-output and
existing-file canaries for runtime arithmetic/dead arithmetic, comparisons,
return, argument/by-reference escape, inline mixed assignment expressions,
nonnumeric assignment and precision17.
The previous F64 cohort remains 23 programs x3; its two mixed-local negatives
move to this positive scope, leaving 9 old negatives. Previous scalar 35x3 and
21 negatives, trace/source-origin/frame checks and production rejection remain.
All measurements use instruction emulation/syscall models and current x86
output, not a fresh Harbour VM oracle or actual Apple platform result.

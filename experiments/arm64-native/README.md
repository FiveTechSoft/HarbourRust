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

The harness covers integer/logical literals, locals/copies/assignment,
integer comparisons, logical short-circuiting, IF/WHILE/EXIT/LOOP, scalar
calls with up to eight arguments, discarded nil-only calls, and formatted
output. All output items are evaluated before the QOut newline, as in hbc.
Nonempty literal strings without a trailing space or an embedded CR/LF can
be printed. Local strings are outside this first boundary.

Every function and AST branch is visited, including unreachable code. Missing
families reject without writing a new output file. They include runtime
arithmetic (overflow-to-double and integer provenance are not ported), floating
point, heap/Dyn values, arrays, hashes, objects, by-reference calls, most
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

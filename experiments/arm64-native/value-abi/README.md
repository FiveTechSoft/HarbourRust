# Isolated pair value ABI and FP boundary probes

Base: d45a960d41b463c7d7fa0a3759fa35d9662c861a, 14 November 2026.

This increment is infrastructure, not source-language support. The production
compiler, the scalar AST experiment, Mach-O writer and Windows prebuilt are
unchanged. No production ARM program is admitted. No Mac loader, Apple Silicon
CPU, actual Darwin syscall or Apple signing-policy result was tested.

## Implemented boundary

The generator emits own ARM instructions, using the published numeric kernels.
It does not translate x86 output, link with Apple's linker, or use LLVM to
produce its instruction bytes. LLVM is an optional independent test oracle.

The private internal convention uses three input pairs in x0/x1, x2/x3, x4/x5.
Each pair is {64-bit numeric payload, 64-bit format}; formats are the published
numeric/ convention. x8 points to a caller-owned writable context. Returns use
x0/x1 for the pair and x2 for the internal status. This is a private generated
convention, not an Apple C aggregate/signature ABI or a public hbc ABI.

An outer/middle/leaf native call chain computes (a op b) op c. All arguments,
the third local pair and context pointer have explicit stack slots. The second
leaf call consumes the returned first pair plus the saved third pair. Integer
overflow-to-double, decimal width/precision and invalid metadata use the
published helpers. Separate three-deep identity calls spill, reload and return
pairs bit for bit, including literal/copy provenance and NaN payloads. Identity
is raw transport, not metadata validation.

At the entry boundary, incoming FPCR/FPSR are saved on the native stack; both
are set to zero with ISB before numeric calls, and restored on both successful
and status-error returns. This avoids inheriting caller rounding, flush-to-zero
and default-NaN settings in this isolated entry. It does not alter the published
scalar harness or establish behavior for traps, signals, foreign unwinding or
every hardware FP feature.

Each native frame links a stack-local record {previous,name pointer,name length,
line}. Error status is returned normally through native frames, not thrown.
Before frame removal, leaf snapshots youngest-first records into a bounded
caller-owned array. The context is 128 writable bytes: top at 0, internal status
at 8, snapshot count at 16, truncation flag at 24, and four 24-byte name/length/
line records at 32. Entry clears result headers but retains an incoming top.
Existing caller chains are restored, and deeper snapshots set the truncation
flag rather than write beyond the array. Names borrow immutable code data;
caller-supplied chains and memory must be valid. Names/lines here are fixed
fixture values, not source-mapped diagnostic strings.

Internal statuses retain their existing meanings: 0 success, 1 zero divisor,
2 invalid numeric metadata, 3 excessive decimal precision. They are not Harbour
error objects, error categories or language diagnostic descriptions.

## Reproduction and measured controls

Copy the whole parent arm64-native directory, not only value-abi, outside the
checkout. Install requirements-dev.txt in a virtual environment as described by
the parent README, then run that environment's Python on value-abi/run-checks.py.
RUSTC can select rustc. Optional LLVM_SHARED_LIBRARY supplies a development
LLVM C API library for the five-word FP system-register/ISB comparison.
The runner writes generated files only into the copied directory.

Measured controls, counted separately:

- 160 FPCR/FPSR boundary combinations: four rounding modes, five FP state flag
  sets, eight incoming status words. Observed state is normalized inside the
  probe; incoming state and SP/FP are restored exactly. Probe creates an invalid
  conversion flag internally before restoration.
- Five new instruction words match independent LLVM Mach-O text bytes. Shared
  encoder unit tests reject reserved/out-of-range GPR operands as well.
- 6,000 emulated nested-call arithmetic/status controls: 1,500 triples for each
  of +, -, *, /. A seeded Python arithmetic/metadata model is the oracle. No
  fresh Harbour VM compatibility oracle was run. This covers finite input
  values, integer boundaries, decimal limits, invalid metadata, both error
  call sites, incoming caller chains and bounded snapshot truncation.
- 70 three-deep identity transport controls preserve payload/format bits.
  Includes integer provenance, signed zero, infinities, NaN payloads and
  unvalidated metadata. Nonfinite arithmetic is not covered by these 70.

The arithmetic test observes SP alignment and untouched x18 at every executed
instruction, and checks x19-x28, SP, FP, FPCR/FPSR and the returned pair/status.
Snapshot headers, order, names, lines, incoming chain restoration and a 128-byte
post-context canary are checked. Emulation is not Apple hardware ABI acceptance.

## Still required before numeric AST admission

This does not implement source argument evaluation/order, arbitrary argument
counts/stack arguments, function signature inference, branch/local type merges,
NumLocal/F64 source tagging, numeric print dispatch, source-mapped diagnostics,
Harbour error descriptions/objects, TRY/CATCH/FINALLY or unwinding. A bounded
fixture snapshot is not the production unbounded diagnostic chain. A returned
status is not a language exception. Complete these boundaries deliberately
before opening the numerical AST, then validate real Mac loading/execution.

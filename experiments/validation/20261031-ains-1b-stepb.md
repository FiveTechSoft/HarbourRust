# ains piece 1b step (b): review snapshot, not original completion

Base: bc364a5c. Read-only ArrayViewReadOnly, distinct from Dyn and hk86
write-borrow. Bootstrap is limited to explicit cell classification evidence
(ValType/HB_IS*/hb_ntos over a parameter cell). Len-only preserves the
existing contract. Forwarding and recursive dependencies use a conservative
fixed point. Mutation, persistence, capture, @ and unknown routes reject;
there is no fallback to moving a view owner.

Header: 24 bytes in a 32-byte caller-frame slot, base 16-aligned. Each
emitted materialization gets a unique slot, including nested/lateral args.
Forwarding keeps the original header. Recursive cells require tag 6 and a
complete child header. NIL descriptors classify as U/false; passing NIL or a
scalar as a view reports PARAM. The owner cannot appear in another argument
of the same call. This conservative restriction includes read-only aliases.

Runtime helper normal return: rax=tag, rdx=payload/child header; rsi/rcx/r8-r11
caller-saved scratch; rbx saved/restored, rbp/r12-r15 untouched. Bounds error
restores rbx then branches to the existing noreturn bound error, preserving
its normal call-entry stack shape on both targets.

Validation (all raw records retained separately):
- ains1b-stepb-final02: strict selected suite ALL GREEN, Linux + Wine,
  78 selected cases plus ABI/cache/inc/parser/shape helper scripts.
- ains1b-stepb-outputguard01: final diff, strict 13 affected cases and helper
  scripts ALL GREEN, Linux + Wine. Direct cell output via QQOut/QOut/OutStd/
  OutErr rejects, keeping borrowed payloads out of generic Dyn cleanup.
- ains1b-realabi02: real emitted runtime, Linux + Wine, AVIEW ABI OK rc0;
  RAW8/TAG16 out untouched, DESC1/2/3 complete headers + slot-tail sentinel,
  NIL out untouched, rbx/rbp/r12-r15 preservation and balanced/aligned rsp.
- Real low/high bounds and NIL/non-array view boundary failures pinned in
  t1466-1469, rc1, including callstack. No stub error path for these tests.
- Registry-instrumented repeated mixed views and DArrS/hb_HKeys report
  hb_memcheck=0 (t1451/t1454), not a claim of zero by construction.
- Oracle byte-exact classification fixtures: mixed without separate space
  items, empty, nested recursion, forward, NIL, nested arguments, DESC3 by
  Array constructor. The fixtures are preparation, not adapted originals.

Preserved failures/limitations:
- Linux reg01: initial broad Len-only bootstrap broke t271/t273; restricted
  bootstrap restores their pins (54/54 Linux reg02, then strict both-target).
- targets01-03 preserve initial fixture mistakes and the local-store escape
  found before the bootstrap correction. These runs are not green evidence.
- final01: wrong expected negative diagnostic for badindex; corrected only
  the nominal manifest pin in final02. No hidden retries or removed failures.
- mixed with separate literal-space output differs: Harbour N C U L vs NCUL.
  Isolated scalar baseline at bc364a5c also gives NCUL. Baseline01 was not
  comparable (Len(DArrDyn) rejected); baseline02 uses FOR 1..4. All outputs
  retained. This does not establish that original aDump is unaffected.
- A four-level nested literal remains rejected by existing literal typing.
  DESC3 coverage uses Array(1,1,1,2), not an adaptation of an original.
- Len(view[index]), direct scalar printing, hb_ntos(Dyn) and the original's
  immediate-output IIF await step (c). aDump original and complete ains are
  NOT claimed supported or closed. No new RC, owned tag-6 cells or tag 5.

Independent verification is still required. This snapshot is not closure.

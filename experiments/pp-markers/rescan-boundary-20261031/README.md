# Overlap/rescan boundary: inactive sequence prototype rejected

Own probes, pinned Harbour oracle. No production source change in this record.

14 initial probes do not justify rule-once suppression: direct self, self-grow,
cycles, self-fallback and fixed-self all return failure in Harbour too. A used-rule
set that silently stops these cases would wrongly accept them. Specific-before-
broad selection matches both definition orders in the measured pair. This does
not establish global priority for every pattern family.

Concrete current gap: BOTH => PROBE alpha ; PROBE alpha. Harbour rescans each
statement to OUT(alpha);OUT(alpha). Current engine applies PROBE to the whole
replacement and consumes the later statement as part of its capture. Nested
sequences and unknown first/last siblings expose the same issue.

INACTIVE.patch tried recursively rescanning every unquoted-separator child using
an immutable Pp. It fixes the simple sequence probes but is NOT an acceptable
increment: all268x4originals still have the same accepted totals21/15Linux,
20/14Windows, yet21original rows change to earlier errors. Generated CLASS
sequences register rules among ordinary statements. An immutable child expansion
cannot execute that temporal state change. 5807prior own fixture differential
also changes21outputs, some merely spacing, others contract effects. Neither
count is a coverage gain. Rejected candidate remains outside src/.

Harbour temporal counterexamples:
- FACTORY ; INNER registers INNER and expands the later sibling.
- INNER ; FACTORY ; INNER leaves the first sibling unchanged, then registers and
  expands only the last one. A whole-output rerun would retroactively change the
  first sibling, which is wrong.
- A factory whose entire result is generated command directives must retain its
  doubled-separator/body grouping. Do not split its body as ordinary statements.
- Command output and call-form translation output have different current phases;
  the latter is not fixed by this command-only prototype.

Minimal next execution model to validate before activation:
An ordered work queue carries each statement's origin, expansion depth and rule
provenance. Apply the existing selection contract unchanged. Replace a command
work item with ordered children and process each child to completion before its
next sibling; register generated directives against mutable Pp at their position.
Keep factory directive bodies atomic according to the existing boundary. Do not
revisit already-completed siblings after a later definition. Enforce depth,
queue-size and output limits across fanout, not only along one recursive branch.
Rule identity records provenance, but no suppression semantics are inferred from
it. Cycles still reject. New rule identity allocation/removal must be temporal,
not vector-position based. This is a design requirement, not implemented support.

Before enabling: exact own pp differential classification, full268x4diagnostics,
all current runtime batteries,14original exact outputs, temporal definition and
removal controls, real hbclass families, nested/quoted/escaped separator probes.
Global latest-naive remains rejected by its prior17original recursion deltas.
No real header VAR/classes,global priority,rescan support,main,runtime/ABI,
ownership,debugger,size/speed or original unlock is claimed by this evidence.

## Ordered queue second inactive candidate

QUEUE-INACTIVE.patch preserves statement depth in a bounded front queue and
processes stateful siblings in order. It handles simple/nested sequence and
factory temporal probes without retroactively changing a prior sibling. Generated
DEFINE/UNDEF as queue items are supported only in this experiment. Adding their
execution removes the first candidate's21earlier original errors:268x4compile
profiles again have0first-diagnostic/exit deltas versus the published baseline.
This does not certify the queue or claim a language increment: full batteries,
original runtime and differential classification have not been run.

New seven DEFINE/UNDEF/removal probes expose remaining directive boundaries:
DEFINE/UNDEF sibling effects match Harbour, while generated UNCOMMAND is not
supported by the candidate (Harbour's measured generated uncommand has its own
behavior and must not inherit direct-source removal assumptions). A DEFINE's
body ends at a generated separator, while COMMAND bodies keep their own factory
boundary. Fixing this boundary in the temp candidate makes generated F(x)=x+1
work for later siblings and later source statements. This intentionally changes
the old t1143 explicit generated-DEFINE rejection; do not alter that expected
rejection without phase/runtime evidence and a clearly admitted new contract.

No queue variant is installed in src/. Provenance, stable rule identity,
output-size budget, all directive scope guards and full gates remain open.

## Identity/provenance experiment, still inactive

QUEUE-IDENTITY-INACTIVE.patch adds monotonic IDs allocated on registration (not
vector positions), with per-work-item rule provenance carried to child items.
It does not use those IDs as a suppression set. Queue10000, depth16 and per-
replacement/per-source-statement emitted output1MiB limits are explicit. Latest
rebuilt candidate again has0first-diagnostic/exit deltas across268x4originals.
No real-header compatibility is inferred from unchanged diagnostics.

Full default battery was run against this temporary compiler: every expectation
passes except old t1143 generated-DEFINE scope rejection. It now passes pp and
fails at no-functions parser phase instead. This intentional boundary change is
not called green, and the test expectation is not changed. LLVM suite and original
runtime checks have not been run on this queue candidate. Production source and
published full-gate counts remain the flags closure.

22 exact pp output/exit deltas against the current flags compiler are preserved.
Most are oracle-correct sequence changes or whitespace normalization. One old
comma-list fused-capture result remains wrong in both versions, though its spaces
change; do not label that token match. Generated UNCOMMAND still becomes an
explicit unsupported-directive error despite Harbour accepting the probe. Its
scope and phase need an admission contract before enabling this queue, together
with generated-DEFINE runtime/temporal witnesses and old rejection migration.

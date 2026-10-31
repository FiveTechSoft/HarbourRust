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

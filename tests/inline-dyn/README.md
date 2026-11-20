# Scalar Dyn inline assignment, ordinary Linux only

Own MIT tests. Harbour is only an external executable oracle.

A scalar Dyn RHS can be assigned inline to a non-byref Dyn local. The expression
returns an independent owned snapshot, not an alias of the target. Clone a
borrowed RHS before releasing the old slot, then clone the installed value for
the result. This preserves self-copy and later target overwrites.

`check.py` compares rc/stdout/stderr exactly in both assemblers, with optional
unmodified external P06. Covers self-copy, nesting, later overwrite, comparison,
concat, return, argument, discard, F64 and NIL. `safety.py` runs1000normal loops
and2000catches per Work after warmup, in three instrumented modes. Profiles and
static shapes outside the increment remain named build rejections.

`diagnostic.py` checks the scalar-only runtime limit for Dyn-held arrays, both
assemblers and inside/outside TRY. It is fatal, not a Harbour catchability claim.
It uses the existing panic exit without changing trace generation or metadata.
`mutants.py` requires successful Rust builds, then detects admission removal,
missing clone before release, and missing independent result clone.

Static F64/string/date inline assignments remain excluded. Array/container Dyn
values are rejected at runtime before the target is changed. This does not add
arbitrary inline ownership, shared-array identity, or Date-in-Dyn support.
No Cmp/Bin arms, workflows, manifests or expectations are changed.

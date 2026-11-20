# Scalar Dyn IIF arms, ordinary Linux

Own MIT tests. Harbour is an external executable oracle only.

The existing mixed-scalar IIF result is an owned Dyn snapshot, restricted to
last output item, Dyn initializer/store and return. This increment accepts borrowed Dyn variable
arms within that same consumer scope. Only the selected arm runs. Borrowed
strings/F64 are cloned. Direct Dyn calls and raw array-cell arms stay excluded.
The selected Dyn arm is screened for scalar kind before cloning, with an
explicit fatal limit for container/object/date payloads. No array identity or
Date-in-Dyn support is added. Static array branches remain build rejections.

`check.py`: exact rc/stdout/stderr against Harbour with both assemblers, including
prompt-style Str/Dyn, Dyn/Dyn, reverse order, lazy calls, return, F64 and later
source overwrite. `safety.py`: three instrumented modes,1000normal borrow/own
and string/F64 overwrite loops plus2000catches in condition/selected static-owned-arm per
Work, warmup then allocation delta0. Five excluded profiles and four independent
shape/scope limits. These are not Harbour error-semantics comparisons.

`diagnostic.py`: scalar-only container limit inside/outside TRY, both assemblers.
`mutants.py`: admission removal and missing borrowed clone. Each mutant must build before a PRG rejection or runtime output
change can count. No Bin/Cmp, trace machinery, workflows or expectations change.

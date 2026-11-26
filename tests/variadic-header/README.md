# Variadic header A

Own programs, specification measured with the pinned compiled Harbour oracle.
No Harbour implementation was read to design this increment.

Admitted: trailing `...` in ordinary functions, direct scalar by-value calls,
PCount and hb_PValue including extra positions. The finite maximum direct-call
arity becomes hidden slots. Existing scalar/NIL padding and lifetime rules apply.

Limits: Linux native only; at most 64 slots; no Main/INIT/EXIT variadic headers,
classes, external functions, MT, macros, blocks or function references.
Forwarding `f(...)`, arrays `{...}` and all other expression splicing remain
named rejections. Container, date, generic Dyn and byref arguments remain
rejected. Nested calls returning generic Dyn remain rejected by that rule.
This does not imply the 43 original ellipsis files now compile. A full 1041
compile-only census remains 65 accepted, zero gains, zero losses.

`check.py --compiler PATH --output NEW_DIRECTORY` verifies exact saved oracle
triples for 8 positives, 14 named limits and non-Linux profile guards, then
runs the shared final-balance guard on every admitted case. Saved expectations
are from fresh compiled-oracle runs recorded in the review evidence.

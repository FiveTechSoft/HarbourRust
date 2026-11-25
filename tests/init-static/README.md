# Persistent STATIC storage in INIT procedures

Own MIT. Ordinary Linux INIT hooks may declare the already supported local
STATIC integer, literal string and constant shared-array storage. Global
persistent initialization already runs before the reverse-order INIT calls,
and persistent cleanup already runs after Main. No runtime code or ordering
change. Bare/NIL returns are still required. Threads/macros, Windows,
float/hash/NIL/logical local STATIC initializers and hook parameters remain
outside this increment.

20 exact triples (four sources across five modes): string hooks ordering,
integer hook storage, shared array mutation/growth, and the formerly rejected
integer declaration. Four named limits and three distinct strict-zero sources.
Original initexit.prg still needs module floats and EXIT hooks, not closed.

The old t1613 negative source is now admitted. Its original is preserved here
and checked against Harbour; the negative fixture now uses a logical STATIC,
which remains explicitly outside this parser increment. Other negative tests
retain their behavior, with the INIT diagnostic text made more specific.
Black-box oracle https://github.com/harbour/core.git at
694428e1c12f726675b19324d62167fa77d68185.

Safety follow-up: thread use is discovered after parsing. A post-inference
check now rejects every INIT static binding in a threaded program before
emission. The earlier compiler admitted the measured thread probe, so its
ordinary-only claim was too broad. Platform/macro and value-return errors
now have separate diagnostics. Six limits cover these boundaries. CLI accepts
only one source unit: a second unit is a measured usage rejection, not a
claim of multi-unit INIT/linking support.

C2 admission follow-up: INIT STATIC NIL and a missing initializer now have
an explicit rejection. The general local STATIC parser also supports NIL,
but that route is not part of this INIT increment. Separate fixtures cover
both forms against Harbour, and hb_threadIsMain() activates the thread exclusion
without starting a worker. No NIL persistence claim is made for INIT.

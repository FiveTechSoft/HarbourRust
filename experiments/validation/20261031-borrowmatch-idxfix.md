# borrow_match stale-moved index fix (33k path), separate correction (2026-10-31)

Bounded diagnosis mandated after the d5aefc35 independent review: the
pre-existing 33k middle-cell borrow path (f(a[i]) DArr2->DArr /
DArr3->DArr2) had the same stale-moved-read shape as the view path -
its post-type_expr env.moved check can never fire, because type_expr
does not apply the index's moves (apply_moves runs per statement).

Repros preserved raw in probes/ains1b-borrowmatch-diag01 (compile rc 0
-> runtime Bound error rc 1; Harbour oracle rc 0 both):
- borrowidxmove2: sink(a[take(a)]), take consumes a (Len(x[1]) pin).
- borrowidxmutate: take mutates x[1][1] := 99.
- borrowidxmove (Len(x) variant) rejected earlier by param pinning -
not affected.

Fix: nominal rejection - an index that mentions the owner array is a
named compile-time error with workaround (compute the index into a
local first). Any mention reaching materialization goes through an
indirect call (a direct mention is not an integer), so the mention
check is exactly the consume/mutate guardrail. hk86 write-borrow
contract untouched: plain/loop-var indices unchanged; no runtime or
emission path touched.

REGISTERED DIVERGENCE (conservative, t1465 family): Harbour compiles
and runs both repros rc 0; this compiler rejects them at compile time.
No byte-exact equivalence claimed for these shapes.

Validation (hr-aeval build, src identical to this commit's tree): both
repros reject with the named error (Linux compile; battery run below
covers both targets for the path); RUNID=ains1b-t412fix-reg01 (36-case
borrow manifest: t394-t408, t412, t416-t423, t484, t489, Linux+Wine)
ALL GREEN; view 54-case and output-guard 13-case batteries ALL GREEN
(same binary). New neg tests t1476/t1477 pin the rejection (rejection
verified manually both targets at the d5 sibling commit; first battery
pass pending).

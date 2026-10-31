# ains 1b step (b) regression fix: t412 ValType over a borrowed param (2026-10-31)

Found during the bounded borrow_match diagnosis: t412_valtype_borrow
(green at bc364a5c, output `A N 0 0 0` rc 0) was rejected at d5aefc35
with "ValType is not measured for this type in this PoC". Regression
introduced by step (b), not a new conservative limit. The (b) focused
manifests (54/78/13 cases) did not include t412 - a manifest coverage
gap, not a validation pass. The full test manifest was red at d5aefc35;
scoped green runs must not be reported as full-manifest green.

Cause: the (b) bootstrap pinned any param with cell-classification
evidence (ValType(p[i]) family) as AView, even when the body also read
the WHOLE param (ValType(p)) - a shape the view contract does not
implement. vt(b[1]) had a working measured contract at bc364a5c (DArr
middle-cell borrow, ValType(DArr) measured).

Fix (t271/t273 rule, conservative bootstrap): two whitelist fixpoints.
STRICT admits only view-implementable shapes (Len whole; ValType/
HB_IS*/hb_ntos over cells). INTENT additionally admits whole-param
reads. Evidence + strict-safe pins the view. Evidence + intent-safe
but not strict-safe keeps the old measured contract (the old path's own
checks still guard it - no unsafe fallback). Evidence + not intent-safe
keeps the pin so the named escape/mutation rejection fires (t1457-t1461
family unchanged).

Also corrects the d5aefc35 comment that claimed AView index
self-mentions "stay legal": a call in a view root's index
(f(s[count(s)])) is rejected by earlier checks (verifier view_selfidx);
the AView exemption in the idx guardrail is defensive only. Registered
limitation, contract not expanded.

Validation (hr-aeval build, src identical to the final tree of this
commit + the borrow_match commit): t412 exact before (bc364a5c
`A N 0 0 0` rc 0) / after (same, rc 0) / manifest expectation match;
negatives t1457-t1461 and t1474/t1475 still reject with their named
errors; RUNID=ains1b-t412fix-reg01 (36-case borrow manifest incl.
t412, Linux+Wine) ALL GREEN; RUNID=ains1b-t412fix-reg02 (54-case view
manifest) ALL GREEN; RUNID=ains1b-t412fix-og01 (13-case output guard)
ALL GREEN. Checker-only change.

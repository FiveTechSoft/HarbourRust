# ains piece 1b step (c)-next: bounded closure - IIF raw Dyn cell arm in
# immediate output (2026-10-31, HEAD 520a6f20)

SCOPE CLOSED (and only this): `iif(cond, ownedStrTemp, rawDynCell)` as an
immediate item of ?/??/QOut/QQOut/OutStd/OutErr. Cond once, lazy arms;
owned arm (no Var) prints then frees (marker tag 7); borrowed cells
print by tag, never freed (DArrDyn string cells are tag 4 owned by the
array; DArrS tag 2); tag 0 int-computed (defensive), 1 NIL, 3 .T./.F.,
6/unknown registered type error, tag 5 reserved. Store/return/pass keep
the generic rejection. Common checker (check_iif_out_rawdyn) and common
cg (cg_print_items) across all output verbs; hbc_print_dyncell in both
runtime copies + auto eprint variant.

INDEPENDENT REVIEW: c6b10774 found one blocker (arm orientation: arms
emitted by kind, not position - wrong side printed, laziness broken for
a dead erroring owned arm). Fixed in 520a6f20; recheck FAVORABLE
(19:37): 10 fresh cases, Linux+Wine rc0 with byte-exact stdout/stderr -
both orientations/conditions, dead-owned-error, cond-once, all four
consumers with 2 items, view root over 12 iterations with owner intact
and memcheck 0. Verifier identity matches (binary 4bdf6f6f..., src
411e2df0...). Failed candidate evidence preserved separately by the
verifier.

VALIDATION ANCHORS (ours): batteries with the unmodified runner,
Linux+Wine - ains1b-stepdfix-02 21/21, regressions stepb-reg 58,
outputguard 18, borrowmatch 41; oracle-exact fixtures t1489-t1500
(t1491 modulo the registered 80-col wrap). Preserved raw failures:
ains1b-stepd-01 (t1492 fixture used target-dependent hb_eol) and
ains1b-stepdfix-01 (my t1498 manifest expectation had field-width
instead of plain hb_ntos text) - both fixture-side, corrected and
re-run under fresh RUNIDs, never relabeled.

NOT CLOSED / NOT CLAIMED: the ains original and aDump byte-exactness
(ledger P1 separator trailing spaces - mechanism now isolated to the
per-statement last-item right-trim applied to ?? where Harbour's QQOut
does not trim; P2 LOCAL-then-assign mixed literal), GT scope, Dyn tag 5,
full LLVM suite. The aDump verbatim driver (local-only) traverses rc 0
with all values oracle-exact, diverging only in P1 separator spaces.

# ains 1b step (c)-next: orientation fix over c6b10774 (2026-10-31)

Independent review of c6b10774 found a BLOCKER: the checker accepted the
raw-cell arm on either side of the iif, but the cg eval emitted the arms
BY KIND (owned on true, cell on false) instead of BY POSITION. A
reversed iif printed the wrong side AND broke laziness
(`? iif(.T., a[2], hb_ntos(a[2]))` evaluated the dead owned arm and
raised the tag-2 type error instead of printing `canary`).

## Fix (this snapshot)

cg_print_items eval branch: the TRUE branch always emits arm1 and the
FALSE branch arm2; the arm KIND (owned string vs raw cell) only decides
each branch's emission (marker tag 7 + free vs borrowed pair, never
freed). Semantic order unchanged; no contract restriction. The checker
(orientation-agnostic validation of the pair) is unchanged.

## New pins (fixtures independent; the two probes come from the
## independent review)

- t1498_stepd_orientation: both orientations x both condition values
  (canary / 1 / 1 / canary), oracle-exact.
- t1499_stepd_deaderror (verifier probe reversed_badowned): dead owned
  arm that would raise a type error is skipped in both orientations.
- t1500_stepd_cond_once (verifier probe cond_once): `++n = 1` condition
  evaluates EXACTLY once.
- t1489-t1494 regression: byte-identical outputs before/after the fix;
  aDump verbatim driver byte-identical.

## Validation (anchors in ~/work/probes/ains1b-stepdfix-impl01)

- Binary: hbc.stepd2 sha256
  4bdf6f6fdbdac982d901193a2b493d5fb253c359481e91bb3668c0588618e071;
  src/hbc.rs sha256
  411e2df0957e967460b58039fb48d4668207fadf2475377b7e17bee1ea2dcb28.
- RUNID ains1b-stepdfix-01 (unmodified runner, Linux+Wine): 20/21 - the
  failure was MY OWN manifest expectation for t1498 (`         1`
  field-width instead of the plain hb_ntos string `1`); the actual
  output was already oracle-exact. Manifest-expectation bug, raw
  snapshot preserved in gen/failures/ains1b-stepdfix-01/.
- RUNID ains1b-stepdfix-02: 21/21 green Linux+Wine (runner unmodified).
- Regressions green Linux+Wine: ains1b-stepdfix-mini-stepb-reg (58),
  ains1b-stepdfix-mini-stepb-outputguard (18),
  ains1b-stepdfix-mini-borrowmatch (41).
- Wine occupied 19:34-19:35 (announced before/after).

## Standing

The independent review's other findings on c6b10774 were favorable
(tag4/2 ownership, duplicated helpers, escape restrictions, loops/mem0)
and are unaffected. t1491 stays byte-exact at 18022B against the
explicitly-adapted SetMode(25,30000) oracle; the default 80-column
oracle wraps at 18247B (registered, same as t1488). Not closed: ains
original / aDump byte-exactness (P1/P2 in the ledger), full LLVM suite
out of scope.

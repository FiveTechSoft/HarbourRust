# Incremental refresh 2026-10-31 @ 7584ef1 (Linux only)

Scope: incremental dependency review after the strings / Replicate /
AEval pieces. NOT a full re-scan; the first-rejection map
(first-rejection-scan-20261031-74e914b.txt) stands as the base.

## Compile bucket re-check (20 units, current tree, linux only)

calling, comments, define, docase, dynwin, exit, fornext, hello,
ifelse, ifinline, lnlenli2, longstr, mem, nums, passref, procline,
recursiv, returns, statfun, while: all BYTE-EXACT vs Harbour
@694428e1 (stdout+rc) on linux. Wine half not re-run (verifier window);
the standing Wine evidence for covered units is unchanged by these
pieces (they do not touch those code paths; AEval/strings/Replicate are
additive builtins).

## Units whose first blocker is now resolved, and what actually blocks them

- arreval: WAS blocked on `aeval`; AEval landed (573d572 + fix 7584ef1,
  verifier review in flight). Intact original byte-exact linux+wine.
- clasname: first error was `aeval`, but true needs are the mixed-type
  array literal, 1-param blocks over Dyn elements, sends on literals,
  CToD/date type and ErrorNew - representation/design pending, not
  near-term.
- sha2: past `replicate`; now blocked on nested string arrays
  ("nested array elements are tagged scalars") + hb_sha2 family -
  representation pending.
- vmasort: needs Val, AClone, ASort, Set(_SET_DATEFORMAT), Date
  arithmetic and a mixed NIL/int/date array - multiple pending designs.

## Frontier unchanged

and_or / errsys: compile, differ only on the error path (default error
handler draws the GT box: Error BASE/1066 ... Quit) - blocked on the
pending GT scope question (asked 07:36, unanswered) and error-system
design. achoice x5: GT pending. adir family: omitted-comma parsing +
ADir FS harness. SET units (video, vmasort): SET design pending.

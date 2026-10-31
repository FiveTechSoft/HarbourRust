# ains piece 1b step (c)-next: IIF raw Dyn cell arm in immediate output (2026-10-31)

Bounded increment authorized by main 31Oct 19:12 CET after the favorable
independent recheck of step (c) (1fe5ad9f). The aDump original's line
`?? iif( HB_ISNUMERIC( aShow[ n ] ), hb_ntos( aShow[ n ] ), aShow[ n ] )`
now compiles and runs; every value is oracle-exact (only the registered
P1 separator-trim divergence remains, a separate correction).

## Shape admitted (checker: check_iif_out_rawdyn, shared by Stmt::Print
## and the QOut/QQOut/OutStd/OutErr call arm; cg: cg_print_items, common
## to every output verb and nested output calls)

- `iif(cond, ownedStr, rawCell)` as an IMMEDIATE output item only:
  cond logical; one arm an OWNED-string TEMPORARY (never a Var - a
  variable's buffer is never freed by printing); the other arm a raw
  borrowed Dyn cell read (Index of an array view or a DArrDyn).
- Store / return / argument positions keep the generic iif rejection
  (t1495-t1497 neg pins).
- Laziness preserved: the condition evaluates ONCE and only the chosen
  arm runs (t1494: the dead arm's side effect never fires).
- Runtime dispatch per tag: the owned arm is marked tag 7 (no real cell
  carries it) and is FREED after printing; borrowed cells print by tag
  and are NEVER freed - CORRECTION to the 19:10 recon: DArrDyn literal
  string cells are tag 4 OWNED BY THE ARRAY (hk254 layout; only DArrS
  uses tag 2), so tag 4 is a normal borrowed string case, not an error.
  tag 0 prints the computed-width integer (defensive), tag 1 `NIL`,
  tag 3 `.T.`/`.F.`, tag 6 (array) and every other tag raise the clean
  registered type error (tag 5 float stays reserved). New runtime helper
  hbc_print_dyncell in BOTH runtime copies (linux + windows); the eprint
  variant is auto-generated (registered in the eprint helper list).
- The aview escape walker admits the bounded iif in output-call
  arguments (the cleanup rule its comment waited for now exists);
  anything else keeps the cell=false rule.

## Validation (anchors in ~/work/probes/ains1b-stepd-impl01)

- Binary under test: hbc.stepe sha256
  c63cdbecb5a88a3271728a1f6f2d99efe48156fdbcfbd4e8c163e0cd53674853;
  src/hbc.rs sha256
  d744546884963a8b7eb4198ab363a61cb7cac9bd9338b67806eaba1d1815bd01.
- t1489-t1494 (pos): ORACLE-EXACT vs Harbour @694428e1 hbmk2 -gtstd
  (fixtures are independent, not Harbour source; oracle runs drop the
  hb_memcheck line, which is ours). t1491 (1000 iterations) matches
  modulo the registered GTSTD 80-column wrap, same handling as t1488.
- t1490 canary: tag-4 (DArrDyn) and tag-2 (DArrS) string cells intact
  after raw-arm printing (concat/print afterwards), hb_memcheck()==0.
- t1492: two iif items per verb across ??, qout, outstd; t1493:
  aDump-shaped recursion; t1494: laziness. All memcheck 0.
- t1480 REPIN (reason): the raw-cell iif is now legal in output, so the
  old neg pin is replaced by the tag-6 runtime behavior: posx rc 1 with
  the registered type error (message keeps the registered "NIL used as
  a number" inaccuracy for non-zero tags). Harbour prints an array cell
  as empty there - registered divergence, now a runtime one.
- Batteries (Linux + Wine, run_battery.sh, strict):
  RUNID ains1b-stepd-01: 1 failure - t1492 FIXTURE bug (hb_eol() is
  target-dependent \r\n on Windows; replaced by target-independent
  `? ""`; raw failure snapshot preserved in
  gen/failures/ains1b-stepd-01/). Not a runtime defect.
  RUNID ains1b-stepd-02: 20/20 green (repin + step-c regression + 9 new).
  Regression batteries, all green: ains1b-stepd-mini-stepb-reg (58),
  ains1b-stepd-mini-stepb-outputguard (18), ains1b-stepd-mini-borrowmatch (41).
- aDump verbatim driver (local-only oracle use, never committed): full
  traversal rc 0, ALL values oracle-exact; only P1 separator spaces
  differ (ledger P1).

## Limitations / registered

- Owned arm must be a temporary (a Var arm stays rejected).
- Expression-position (value) output calls nested inside other
  expressions share the same path; store/return/pass rejected.
- tag-5 float cells: reserved, registered error (no authorization).
- hbc_type_error message names NIL for every tag (registered).
- P1 (separator trailing trim) and P2 (LOCAL-then-assign mixed) remain
  open in the ains ledger; they are separate corrections after this
  validation.

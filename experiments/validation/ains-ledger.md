# ains piece ledger (rolling; ordered work: 1a done, 1b steps (b)/(c), then pieces 2/3/4, then the full original)

## Pre-existing blockers for the ains original (registered 2026-10-31, with repros; corrections to come as SEPARATE commits after the IIF raw-cell arm is validated; homogeneous-literal and ownership contracts must be preserved)

### P1. Separator trailing spaces trimmed in `?`/`??` output
Repro (probes/ains-preblockers01/trim-sep.prg):
`?? "Len=" ?? ": " ?? "x" ?? ", " ?? "y"`
- Harbour @694428e1 hbmk2 -gtstd: `Len=: x, y` (rc 0) - trailing spaces preserved.
- HarbourRust (cd62b1ec and 1fe5ad9f): `Len=:x,y` (rc 0) - trimmed.
- Attribution: pre-existing at bc364a5c (baseline02, `N C U L` vs NCUL on
  literal-space items); NOT caused by array views.
- Impact: the ains original's separators (`"Len="`, `": "`, `", "`) all
  carry trailing spaces, so aDump cannot be byte-exact until this is
  resolved. Blocks piece (d) acceptance, not compilation.

INVESTIGATION 31Oct (oracle matrix q1-q10, probes/ains-preblockers01;
candidate untouched): Harbour's rule is trim-at-FLUSH, not per-statement:
trailing spaces are dropped only when a newline (a later `?`'s leading
newline) or program exit flushes the line; mid-line they survive across
any number of `??` statements (q6: `?? "ab  "` `?? "y"` `? ""` ->
`ab  y\n`; aDump's `": "`/`]= "`/`, `"` survive the same way; q9/q10:
a line still open at EOF IS trimmed). One-space separators exist between
items in BOTH `?` and `??` (q1/q3); numbers print in their field (q2/q8,
already pinned by hk327/hk328). OUR implementation right-trims the last
visible item of EVERY statement (? and ?? alike), which coincides with
Harbour only when the statement end is the line end. Divergences:
P1a `??` last item trimmed although more `??` output follows (the aDump
blocker); P1b `? "ab  "` followed by `?? "x"` trims early (`abx` vs
`ab  x`); EOF behaviour matches by accident. The cg comment claiming
"?? trailing right-trim identical to ? (hk274-hk276)" has NO hk274-276
fixtures in tests/ - provenance of that pin unresolved, verify before
the fix design. Fix sketch (separate increment, NOT started): hold the
last string item's trailing spaces as a pending count in the runtime;
every print-helper entry re-emits held spaces first, except the newline
flush and program exit, which drop them. Must cover ALL render sites in
cg_print_items (string, darrs_elem, darr2_child, the new iif raw-cell
arms) and prints from inside called functions (t1494's side() case), so
the mechanism belongs in the runtime helpers, not in cg. OutStd/OutErr interleaving resolved by q11-q15: OutStd drops the hold,
OutErr leaves it untouched.
RESOLVED 31Oct 20:34 (review snapshot, commit follows this ledger line):
implemented as hbc_pending/hbc_pstrt/hbc_pflush + per-site flushes in
cg_print_items; q1-q21 20/21 (only the pre-existing all-spaces edge
q19), aDump verbatim driver byte-exact, 139-case battery ALL GREEN
Linux+Wine. Record: experiments/validation/20261031-ains-1b-p1.md.
Independent review pending; not closed.

### P2. `LOCAL x` separated from a mixed-literal assignment is rejected
Repro (probes/ains-preblockers01/local-then-assign.prg):
`LOCAL x` / `x := { 1, "a" }` / `? valtype(x[2])`
- Harbour: rc 0, prints `C`.
- HarbourRust (1fe5ad9f): compile rc 1 "type mismatch in assignment to `x`".
- `LOCAL x := { 1, "a" }` (single statement) works; only the split form
  fails. The Harbour originals declare locals first and assign later.
- Impact: the ains original cannot compile unadapted until the split
  form pins the same way. Blocks piece (d) compilation.

INVESTIGATION 31Oct (candidate untouched): the failure is NOT about
mixed literals - a bare `LOCAL x` pins a Dyn slot (16B {tag,payload}),
and the Dyn-slot assignment arm (check_stmts Stmt::Assign) admits only
I64/Bool/Dyn/Str/StrOwn. EVERY array shape is rejected:
`x := { 1, "a" }`, `{ 1, 2 }`, `{ "a", "b" }`, `{ 1, NIL }`, while
scalar `x := 5 / "s" / .T.` all work (Dyn re-tagging, probe n2). The
ains original uses this pattern throughout: LOCAL aFirst/aSecond/aMore
then `aSecond := { 1, 2, 4 }` (twice), `aFirst := AClone(...)`,
`aMore := { { 1, 2 }, { 3, 4 } }` - so P2 is a HARD requirement for
piece (d), not a corner case. Options: (a) Dyn slots gain tag-6 array
ownership - the slot holds tag6 + buffer pointer (the array buffer is
self-describing: count word at base), the epilogue/reassignment frees
it (deep free via the existing helpers), ValType reads "A", function
passing reuses the classification machinery. Harbour-true, but it
CROSSES THE LIVE BOUNDARY "no owned tag-6 array cells" - needs explicit
authorization, plus an ownership design (reassignment frees the old
array; moves; what a Dyn-held array means for the view/borrow rules).
(b) Re-pinning a bare LOCAL on first assignment breaks the accepted
n2-family re-tagging (x := 5 then x := "s" today works) - REGRESSION,
rejected. ESCALATED to main 31Oct; no implementation without a decision.

## aDump recon (2026-10-31, probes/adump-recon01; aDump verbatim body used
locally as oracle ONLY - never committed; driver is NOT the complete ains)

- Oracle rc 0 trace captured (aDump over {1,2,"3"}, {1,NIL}, {{1,2},{3,4}}):
  raw-cell iif arm prints string cell content (`C:3`) and literal `NIL`
  (`U:NIL`); separators keep trailing spaces (see P1).
- Current compiler (1fe5ad9f): the FIRST rejection is the raw Dyn iif arm
  at `?? iif( HB_ISNUMERIC( aShow[ n ] ), hb_ntos( aShow[ n ] ), aShow[ n ] )`
  ("branches must share a scalar type, got StrOwn and Dyn"). Everything
  before that line passes the checker. This is NOT proof of no later
  failure: a discovery probe with the iif line neutralized (labeled,
  arm-substituted, semantics NOT the original's) compiles and runs rc 0
  with the recursion/nesting/HB_ISARRAY structure intact - discovery
  only, differences vs oracle registered (trim, substituted arm).
- Next bounded change (pending verifier findings on step (c)): IIF raw
  Dyn arm in immediate-output consumption - print by tag without freeing
  the borrowed arm; owned arm freed after print; tag-6 to scalar print =
  registered error; non-immediate consumption stays rejected.

## Open decision queue (unchanged)
Dyn float tag 5 (reserved, no authorization); GT scope (blocks achoice
family); RC/shared-alias (out of current scope by construction); t528
open. Step (b) closed bounded (20261031-ains-1b-stepb-closure.md); step
(c) snapshot 1fe5ad9f under independent review.

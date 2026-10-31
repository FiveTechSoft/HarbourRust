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

### P2. `LOCAL x` separated from a mixed-literal assignment is rejected
Repro (probes/ains-preblockers01/local-then-assign.prg):
`LOCAL x` / `x := { 1, "a" }` / `? valtype(x[2])`
- Harbour: rc 0, prints `C`.
- HarbourRust (1fe5ad9f): compile rc 1 "type mismatch in assignment to `x`".
- `LOCAL x := { 1, "a" }` (single statement) works; only the split form
  fails. The Harbour originals declare locals first and assign later.
- Impact: the ains original cannot compile unadapted until the split
  form pins the same way. Blocks piece (d) compilation.

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

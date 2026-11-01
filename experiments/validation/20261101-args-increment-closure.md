# Args increment closure record (2026-11-01, post independent review)

Scope: closure of the parser-args increment 92947baf after independent review.

## Verified by independent reviewer (01:41-01:42 CET)
- Content identity: patches applied clean on c212a9a6 reproduce the anchors
  src/hbc.rs sha256 2b9a5d6ba060740168d6646a4b1e134ecff65ac6a6d41fc127de6154b7c9419f,
  tests/manifest fae2c9a8..., tests/run_battery.sh ea581c81... (unchanged).
- Behavior: 9/9 manifest fixtures byte-exact on reviewer's own rebuild (Linux);
  5 positive + 2 negative byte-identical on Wine. Repins t718/t719 oracle-validated.
- Topology: real git bundle c212a9a6..f1745794 verified FF; 92947baf direct parent
  cd42f3fa; merge-base confirms c212a9a6 ancestor of 92947baf and 92947baf ancestor
  of tip f1745794. diff 92947baf..tip over src/ + tests/ is EMPTY - no compiler
  change entered after review.
- Oracle provenance: ork271.prg source anchored; its 5 output rows match ork271.out;
  t718/t719 reproduce the p()/q() rows respectively.

## Explicit limits (not claimed, per review scope)
- No binary hash equality (reviewer rebuilt from source; dist binary not compared).
- No independent full 1529-case battery (reviewer ran the 9 manifest fixtures).
- No LLVM-backend claim.
- Nested RHS via IdxCompound is the pre-existing parexpr path and matches the
  Harbour oracle (8/6 both forms); not a new admission.

## Behavioral note
The increment admits omitted arguments as NIL in every position and inline
ident := expr assignments inside call arguments. Six original sources advanced
past their previous parse failure (video2, win_os, win_reg, runshell, dirrec,
xhbmisc); this is recorded as an advanced first-error position only, NOT as
compatibility of those units.

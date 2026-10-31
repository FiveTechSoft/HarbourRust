# ains piece 1b - P1 (print flush-trim) BOUNDED CLOSURE, 31Oct 20:46 CET

CLOSED within this exact scope, on independent review of e3a04602
(tag ains-1b-p1fix-review):
- 17 fresh cases, both Linux and Windows/Wine, rc 0, raw stdout AND
  stderr byte-exact against fresh Harbour @694428e1 oracles: the q11-q17
  interleaving set, the Dyn-empty-string and empty-cell regressions
  (q22/q23 shapes), OutStd empty/non-empty hold semantics (q24/q26
  shapes), OutErr channel separation, and a 37-space hold crossing two
  20-byte flush chunks. Own ABI canaries for hbc_pstrt/hbc_pflush:
  stack alignment, rbp/rbx/r12-r15 intact on both OS.
- Identity verified by the reviewer: commit e3a04602, src sha
  bdfc152c..., binary sha 70df2c37... (matches anchors-p1c.txt).
- Writer-side supporting evidence (NOT independent): q1-q26 expressible
  matrix byte-exact except q19; regression battery p1c-204204 139 PASS
  ALL GREEN Linux+Wine with anchors start == end.
- Verifier report + harness preserved: probes/ains1b-p1-impl01/verif-p1fix/.

Explicitly OUTSIDE this closure (no claims):
- q19 (`? "a", "   "`: Harbour's flush-trim also eats the separator
  before an all-spaces trailing item) - PRE-EXISTING registered edge,
  pre-P1 binary byte-identical; needs a buffered line. NOT fixed, NOT
  claimed.
- q25 (iif over a nested-array cell) - not expressible; the checker
  rejects subarray-by-value extraction (named limit pre-P1).
- The aDump 151-byte verbatim driver was verified byte-exact by the
  writer at 309ca578 AND re-run by the writer on e3a04602; the
  independent reviewer confirmed it at 309ca578 and did NOT re-execute
  it independently on the fix. No independent-fix claim for the driver.
- The full original ains: NOT compiled, NOT claimed.
- No full/strict LLVM-suite claim; the 139-case battery is the curated
  regression set, writer-run.
- stderr print trim semantics beyond the probed cases remain unprobed;
  the 17-case result does not generalize to all output shapes.

P1 mechanism now in src (both runtime copies): hbc_pending hold +
hbc_pstrt/hbc_pflush + per-site conditional flushes in cg_print_items
(formatted sites only; Dyn/dynlit/dyncell conditional on runtime
tag/len; raw OutStd/OutErr never touch the hold; `?` newline and
program exit drop it).

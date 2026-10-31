# AEval piece evidence (2026-10-31) - CLOSED by independent review

Piece: AEval(a, b [, nStart [, nCount]]) statement under the one-by-one
originals commission + 25Oct array scope (dynamic/multidimensional
arrays, Harbour behavior parity; RC/alias/cycles NOT approved).
Result: the intact original tests/arreval.prg (sha256
46ae515cde1b6bdcd886eadbccb610ee10e1d2128e7d231b90486486a0c67ed5,
122B source) runs BYTE-EXACT (66B output) vs Harbour @694428e1 on
linux AND windows/wine. Fourth new original after fib, parexpr, t1.

Commits: 573d572 (initial) + 7584ef1 (verifier-driven fix).

## Failed prefix (preserved, not carried over)

573d572 battery 1414/0 (prefix-battery-573d572-1414.log) and verifier
evidence (prefix-573d572-verifier-evidence/): 9/12 cases exact, 4 bugs
found - (1) side-effecting start/count evaluated twice (desugar cloned
args), (2) negative start skipped count evaluation, (3) s+count-1
overflowed before clamping, (4) line-numbered temp names could collide
with a user local. Fixed in 7584ef1 with guardrails t1417-t1421;
AEval() zero-arg also moved to the precise arity rejection.

## Final validation (7584ef1, tree aff1d36e481e874c4b788bd651ccbfd6675cd5d4)

- Battery: 1419 PASS / 0 FAIL linux+wine (battery-7584ef1-1419.log),
  independent of the prefix battery.
- Guardrails: oracle vs HR linux outputs in guardrails/ (single-eval
  order, args-evaluated-when-empty, end overflow, hygienic temps).
- Independent verifier closure 16:09 (verifier-evidence/): 19 positives
  Linux+Wine oracle-exact without retry, 7 negatives x 4 contexts
  nominal, the 4 bug fixes + 2 same-line semicolon calls pass, original
  arreval 66B output exact against the intact 122B source.

## Scope (do not widen)

Statement-position AEval only; 2-4 arguments; array variable as first
argument; integer-element arrays (element-typed block args keep the
"codeblock arguments must be integers" limit). Expression position
(the array return = alias semantics), captures, array mutation through
the block, and mixed/string elements are named rejections. No LLVM
claim, no gate run for this piece.

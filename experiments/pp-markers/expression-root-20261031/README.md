# Bounded expression-root capture plan

Own MIT implementation. Harbour is a behavioral oracle, not source for the code.

Contract: literal command head, required plain expression root, one to six
independent optional clauses, each a literal flag or literal plus plain expression.
Distinct literal anchors; no nested clauses, list/restricted/wildcard captures,
required suffixes or translation-prefix mode in this plan. Existing global
literal-score/order priority is unchanged. Candidate rules must fully match.

Capture boundaries are lexical, not semantic compiler validation. Source spans
supply adjacency for date prefixes and concatenated macros. Independent clauses
retain their iteration and capture ownership; repeated captures without associated
result groups do not match. 1024 clause iterations maximum. Source tokenization
separates comparison '<' from pattern markers. Normal/smart stringify of a single
macro differs from dumb stringify, tested against Harbour.

22 plan unit tests;8ownfixtures exact freshHarbour/default/LLVM. Full local and
independently reconstructed candidate:1352default=1347manifest+5aux,714LLVM.
14 unchanged reviewed Linux originals exact all3engines;268x4 original compilation
audit zero diagnostic/acceptance changes, totals21/15Linux20/14Windows.
30929historicalsources138deltas138freshoracle matches. Research sources and
rejected alternatives preserved under expression-plan-research-20261031.

Not a general expression parser, not full METHOD/hbclass support. Historical
.NOT./**/!= and plain literal normalizations are not claimed exact. Large seed
comparisons report exact and normalization-excluded results separately.
No class runtime, ownership, ABI, debugger, main, byte-size or speed changes.

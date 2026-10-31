# Reusable expression-root plan: INACTIVE research

Own MIT implementation, pinned Harbour oracle. No production source changed.
The current patch retains a conservative expression boundary with lexical indices
and terminal operators. Harbour command captures New + even though compiling that
expression may fail. Operators only terminate at end, never before an operand
named AS/DECL. Existing result-iteration ownership is reused, including no-match
for repeated captures outside associated result groups.

Fresh conservative results:
- 81/81 expression matrix (previous patch 74/81).
- Seed 3817: 1826/1826, including 26 repeat/reorder controls.
- 30903 historical sources: 112 deltas, 112/112 fresh Harbour oracle matches.
- Prior original audit was zero changes before these refinements, NOT rerun.
- Full repository batteries/runtime14/independent remote NOT run.

Still NOT ready: expanded controls expose unsupported expressions falling through
where Harbour translates (logic, decimal, alias, messages, macros, multiple array
indices). Do not silently remove existing captures or activate for real METHOD.

Rejected broader lexical scanner is retained separately, never active:
- Also passed 81+1826 narrow cases.
- Seed4197/3000: 2492 matches,508 differences (includes operator normalization
  differences and genuine false translations).
- METHOD 1e2 should remain unmatched; broad scanner translated it.
- METHOD &x. DECL: scanner swallowed DECL into root capture; Harbour does not.

Generalization needs a source-aware lexical capture contract, numeric validation,
macro terminating-dot semantics and distinction between unsupported/no-match.
No global priority, class runtime, ABI, ownership, main, byte/speed claim.

## Refined scanner v2, still inactive and not current candidate

Numeric atoms and macro terminator are now explicit. Seeds4197/3000 and
4198/5000 have no capture mismatch after separately excluding historical
.NOT.=>! and **=>^ normalization differences (exact matches2760/3000 and
4532/5000 respectively). These are NOT exact compatibility passes.
Expanded seed4199/5000 has4236 exact matches; remaining differences include
normalizations and false translations because whitespace/adjacency was lost.
Source-adjacency-oracle26.json demonstrates d"date" vs d "date", and pre&x.
vs pre &x. A token-only contract cannot safely decide these boundaries.
Restore conservative candidate; next prototype must carry source spans and
adjacency into expression capture. Do not patch global source tokenizer merely
to admit this plan. Production still unchanged; no closure gates rerun.

## Source-aware v3: INACTIVE

Captures receive an adjacency bit per source token from existing source spans.
Date prefix and concatenated macro boundaries no longer guess whitespace.
Experimentally tokenize source '<' as comparison, never pattern marker; this
is a shared-source-tokenizer change and requires independent gates before use.
Seed4199:4561/5000 exact;439 normalization-only differences under explicit
.NOT./**/!= normalization. These are NOT5000 exact passes.
Replay30929sources138deltas137matches1newfalse stringify:
`METHOD &x. DECL` with result `<"name">` needs bare x, not quoted &x.
This is smart normal stringify semantics, not merely capture identity.
No production activation, no new repository/runtime/original audit gates.
Conservative patch still stored independently as group_plan.rs.patch/pp.rs.patch.
Next isolate plain result support from special marker semantics or implement and
oracle-test the source-aware stringify contract before considering activation.

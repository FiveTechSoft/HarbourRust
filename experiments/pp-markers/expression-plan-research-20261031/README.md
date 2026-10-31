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

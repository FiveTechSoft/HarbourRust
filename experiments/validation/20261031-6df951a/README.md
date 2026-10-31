# Replicate piece evidence (2026-10-31)

Piece: Replicate(c,n) builtin (bounded groundwork under the originals
support commission; unlocks no original by itself; no LLVM claim).
Commit 6df951a, branch experiment/llvm-scalar-aot.

## Validation that exists

- Battery (Linux+Wine): ALL GREEN 1408 PASS / 0 FAIL
  (battery-1408-green.log). History: battery-attempt1-t1369-premise-conflict.log
  failed t1369, a pre-existing neg test whose premise (Replicate is an
  unknown function) the builtin invalidated; the guarded hole is
  unchanged and the test was re-pointed to a genuinely unknown name.
  The recovered positive shape of t1369 is kept as its own observable
  positive test t1411_replicate_userfn_arg.hb (oracle expectation:
  "\nababab"), without replacing the neg guard.
- Oracle provenance: every expectation from Harbour @694428e1 runs.
- Independent verifier closure 15:42 (verifier-evidence/): 8 positives
  Linux+Wine oracle-exact including the recovered t1369 body; 8
  negatives x 4 contexts nominal; instrumented memcheck 0 (ownership);
  overflow fails clean in HR (no Harbour error equivalence claimed);
  tree 8e4b167b2e9a6cf1baff876507764c4c282f3487 / remote 6df951a
  identity confirmed. No new original, no new LLVM.
- Scope: Replicate(c string, n integer) only; wrong types/arity are
  named rejections (t1407-t1410); count<=0/empty source -> empty.

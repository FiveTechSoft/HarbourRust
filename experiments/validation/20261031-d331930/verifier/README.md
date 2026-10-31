# Independent verifier evidence for d331930 (received 2026-10-31 08:13-08:14)

Provenance: the traversal/verifier task agent's own executions of
d331930 and the Harbour reference, forwarded by main. Not OpenCode
runs. Filenames as received.

- results-6de7d717.json: five-case semantics comparison (bounds_rhs_order
  found the material defect fixed after d331930; nested_rhs and
  rhs_old_cell matched; shadowed_root rejected by both; overflow is the
  registered I64 wrap limit).
- bounds-observed-f4c808e2.json: the HR-executed confirmation of the
  defect (variable index i=0: RHS-EFFECT printed before the bound
  error; Harbour ErrorBlock harness catches without the rhs effect).
- verify-d331930-default-ca0e1ad4.log: default battery, 1355 green.
- verify-d331930-llvm-full-120616fd.log: full LLVM gate, 714 checks PASS.
- results-9779bc02.json: 14 originals byte-exact three ways.
- verify-d331930-audit-7492a89f.json: 268x4 acceptance audit, no new
  acceptances (8 diagnostic deltas arrayidx/sha2).

# ains 1b increment 1 - bounded closure (2026-10-31)

Scope: HB_ISNUMERIC/HB_ISARRAY builtins on measured shapes (ains piece 1b,
first increment). No owned tag-6 arrays, no float tags, no LLVM gate changes.

Independent verifier closure (evidence: identity-92c00b21, results-204f00ed,
negatives-d5320657): commit d213539e5f455c5e0e33794a28720cf792942be1, tree
962fd73b1da009acd92b8a403a8864995e610417, remote observed identical.
- 8 guardrail repros x Linux+Wine: all nominal named rejections, no codegen
  panic (blockvar/hashvar/floatindex/stringindex/unknownindex/movedowner/
  zeroargs/dynvar), pinned as t1438-t1445.
- 4 positives Linux+Wine oracle-exact (published prefix, old t1426 repin,
  effects-once, t1437 byte-exact).
- Effects evaluated once; 5 Wine cases, 0 retries; Wine released 17:58:59.

Registered separately (not closed, not attributed to this increment):
- Failed prefix 1ab753da and its run1b1 failure snapshot (manifest still
  pinned the pre-1b t1426 text; raw snapshot preserved).
- run1b2/run1b3 focused runs (single attempt each, run anchors in the
  validating working copy: gen/run-run1b2.header, gen/run-run1b3.header).
- Unmeasured shapes stay named rejections: Dyn variables, Index2, Hash and
  Block variables, arbitrary expressions, non-integer indices.

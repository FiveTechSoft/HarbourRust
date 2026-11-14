# Escape-analysis classification battery (Goose-hybrid I1)

`hbc --no-escape-analysis` omits the pass; `HBC_ESCAPE_DUMP=1` prints the
classification to stderr. The pass is pure analysis: it changes no codegen.
The `.exp` files are unchanged from the original reviewed I1 implementation.
They use its frame-escape, transfer/clone and scope-annotation interpretation
of the design proposal, not a claim that allocation changes are implemented.
See the status notes in the design doc
(`docs/harbourrust-goose-hybrid-design.md`, Incremento 1):

- 01 returned value: ESC (rule 1).
- 02 loop temp printed only: NOESC, loop-local (the doc's first-prototype case).
- 03 loop temp stored into a function-level container: NOESC with
  crosses-scope (the container's lifetime, not the iteration's).
- 04 container returned: ESC; the classification reaches stored values
  through the union with the container.
- 05 owned move into a call: ESC; a read-only builtin (`len`) borrows: NOESC (rule 6).
- 06 `@x` by-reference: ESC on both sides (rule 5).
- 07 recursion: ESC by the generic owned-move rule; the pass has no
  interprocedural deduction, so there is no cycle to cut.
- 08 iif transfer: the taken arm moves into the result; the union
  propagates the return's ESC to both arms (rule 7).
- 09 STATIC: process-owned, always ESC (rule 3).
- 10 Dyn returned: NOESC. Dyn values are cloned at the boundary
  (cg_dyn_clone_if_str); the local's own payload still dies at the
  epilogue. Clone semantics are not escapes.
- 11 early EXIT from the loop: classification is flow-insensitive and
  unchanged; t still crosses-scope (adversarial case from the doc).

Run: `tests/escape/run.sh` from the repo root.

The classification gate is 11/11. Tests 02, 03, 07 and 11 use block/late LOCAL declarations that official Harbour rejects; they are classification-only, not same-source oracle passes. The other seven sources pass 14 paired stdout/stderr/status checks in normal and instrumented modes.

I1 has no allocation or codegen consumer. Later arena/reference work needs separate review of the classification proof, including unknown/fallback cases.

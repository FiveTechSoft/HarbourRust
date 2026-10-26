# Sondas (oracle probes)

The `.prg` files in this directory are OUR measurement probes
("sondas"), not original Harbour sources. Each one is compiled with the
pinned Harbour build (harbour/core at commit 694428e1, `hbmk2 -gtstd`)
and its observed behavior is the oracle that a compiler increment is
designed against - the probes are written first and the compiler
follows them, never the other way around.

They live in the repository so the evidence behind published claims
stays re-runnable (labels `hk<N>` match the references in
docs/BATTERY.md):

- hk254: array literal shapes - all-string LEN/concat, homogeneous
  nested, heterogeneous leaf VALTYPEs.
- hk255: self-recursion re-lending an `@` borrow prints 0 (same source
  as tests/t643_byref_recursion.hb with `Main` capitalization).
- hk256: discarding a returned array is legal; the callee's side
  effects still run.

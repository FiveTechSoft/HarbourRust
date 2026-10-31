# Pre-existing display-width limit vs Harbour (registered 2026-10-31)

`? <var>` of an i64 local initialised from a positive literal with 10+ digits
prints width 10; Harbour @694428e1 (-gtstd) prints width 11 because Harbour
items carry a stamped display length (itemapi.c) that this LLVM-subset
runtime does not model. Same root cause: AAdd-grown integer cells keep the
literal's stamped length (11) where this runtime prints the macro width (10).

Independent audit (same probe, source sha256
ec4cc4ca1e081c7e4fb010eac0ad4bbd12220ee03eb2940b1a51476ee75f31e0) across four
commits, plus this agent's three-binary cross-check (probe /tmp/wv.prg, source
sha256 b5498106593e6961b94c1dbf1972e754282699022ab96e24ec0da9c1df4ed64a):

| commit / build   | hbc sha256 (prefix) | `? x` where `x := 2147483647` |
|------------------|---------------------|-------------------------------|
| 6e65a2e (pre-arrays) | beed0456459e | `2147483647` (w10) |
| 5085ee9 (piece-1a base) | 76a05dc409a3 | `2147483647` (w10) |
| 37873e4 (verifier-built) | 977e321d25ac | `2147483647` (w10) |
| 7b5387a / current | c3c3090026ad | `2147483647` (w10) |
| Harbour oracle   | -                  | ` 2147483647` (w11) |

`? x+1` (runtime-computed) prints w10 everywhere including the oracle.
Attribution: PRE-EXISTING at the pre-arrays tag 6e65a2e; NOT introduced by
the piece-1a scalar/dyn width split. The only width delta the split
introduced vs 5085ee9 is DArrDyn literal cells w10->w11 (oracle-justified,
verifier-confirmed "mixed cell Max exacto"). Status: registered limit, not a
regression; any fix requires runtime per-item display-length metadata and is
a separate proposal, not part of the arrays slice.

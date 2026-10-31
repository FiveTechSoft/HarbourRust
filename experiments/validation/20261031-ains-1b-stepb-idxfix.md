# ains 1b step (b) fix: sub-view index consume/mutate guardrail (2026-10-31)

Independent review of 243209ae (verifier bundle
view243209ae-independent-report) found ONE blocker, two repros, both
targets:

- index_consume_only: `f(a[take(a)])`, take consumes `a` -> compiles,
  runtime Bound error rc 1. Harbour oracle: rc 0 (`\n         2\nN`).
- own_index_mutate: same shape, take mutates `x[1][1]` -> runtime Bound
  error rc 1. Harbour oracle: rc 0 (`\nN`).

Root cause: the sig_aview Expr::Index argument arm validated
type_expr(index) and then read env.moved, but type_expr does not apply
the index's moves (apply_moves runs per statement, after the whole
statement). The moved check read stale state and the sub-view
materialized from a consumed/mutated owner.

Fix (this commit): nominal rejection in that arm - if the index
expression mentions the viewed array of an OWNED root (DArr2/3/4), the
program is rejected at compile time with a named error and workaround
(compute the index into a local first). Any mention of an owned root in
its own index can only reach materialization through an indirect call
(a direct mention is not an integer), so the mention check is exactly
the consume/mutate guardrail. AView roots are exempt: the read-only
view contract already forbids consuming or mutating a view, so
`s[len(s)]`-style self-mentions stay legal.

REGISTERED DIVERGENCE (conservative, t1465 family): Harbour compiles
and runs both repro programs rc 0; this compiler rejects them at
compile time. Not byte-exact equivalence for these shapes; do not claim
it. Workaround for user code: `local i := take(a)` then `f(a[i])`.

Validation (hr-aeval scratch build, src identical to this commit):
- prefail runs preserved raw: probes/ains1b-stepb-idxfix-prefail01
  (compile rc 0 -> runtime Bound rc 1 Linux; Harbour oracle rc 0 both).
- postfix: both repros compile-time rc 1 with the named error on BOTH
  targets (Linux and Windows compile).
- RUNID=ains1b-stepb-idxfix-reg02 (54-case focused view manifest,
  Linux+Wine) ALL GREEN.
- RUNID=ains1b-stepb-idxfix-og01 (13-case output guard manifest,
  Linux+Wine) ALL GREEN.
- New neg tests t1474/t1475 pin the rejection.
No full LLVM suite, no 78-case repeat (per main: scoped recheck only).
No ABI/memcheck re-probe: the change is checker-only, no runtime or
emission path touched.

Known separate risk (NOT fixed here, by scope): the pre-existing
borrow_match 33k path (f(a[i]) DArr2->DArr middle-cell borrow) has the
same stale-moved-read shape for f(a[g(a)]) with g moving the root.
Diagnosis and separate correction to follow with the hk86 write-borrow
contract intact.

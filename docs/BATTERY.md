# Battery evidence model (since the QOut audit, 2026-10-25)

`tests/manifest.txt` is the versioned record: one line per test,
`pos <file> <escaped expected stdout>` or `neg <file> <error substring>`.
Positive expectations are derived per category, not assumed:

- **HB-EXACT** (58 tests): bytes captured from the Harbour 3.2.1dev
  reference compiled with `-gtstd` (clean stdio, no ANSI console codes).
  The earlier quick oracle (`hbmk2 file.hb` script mode) runs ONLY the
  first function in the file, not `main` - it was never valid for
  multi-function tests and is no longer used as an oracle.
- **HB-ADAPT-MATCH** (7: t13, t20, t23, t28, t31, t48, t52): Harbour
  rejects the original file (LOCAL after an executable statement). The
  adapted variant (LOCALs hoisted to the function top, semantics
  unchanged) compiles under Harbour and matches our output BYTE-EXACTLY.
- **MODEL** (4: t11, t25, t54, t15): the adapted variant changes meaning
  under our ownership model (move/revive) or is invalid Harbour outright
  (t15: block-scoped duplicate LOCAL; Harbour locals are function-scoped).
  Expected output is our own; the difference is the Rust model, by design.
- **DIVERGE-NUMERIC** (2: t45, t46): Harbour does NOT terminate - its
  double counter cannot advance past 2^63 (observed: 20s timeout while
  printing repeated values). HarbourRust (i64) terminates bounded with
  exact output. Registered model difference, not a bug to fix.

Audit corrections from the QOut review:

1. Earlier "MATCH" labels were computed with whitespace normalization.
   Harbour `?` pads integers to a 10-column field and emits the newline
   BEFORE the items (QOut semantics) - all prior integer MATCH claims
   were not byte-exact. The current battery is byte-exact.
2. The battery runner previously executed STALE binaries when a build
   failed, masking two genuine compile failures (t61: for-bound did not
   pin the parameter type - fixed by pinning for-bounds as i64; t62:
   `id(x)` with only `return x` is beyond the PoC's inference - test now
   pins via `x + 0` with a comment; reverse call-site inference is a
   registered limit). The runner now fails loudly on any build error.

`?` byte semantics implemented (probes b51-b59, q1-q6): evaluate ALL
items first (side effects of calls happen before the newline), then one
newline, items joined by one space, integers right-aligned in a field of
max(10, digits+1) for positives and 10 (or 20 past 10 chars) for
negatives, strings raw (UTF-8 passthrough), no trailing newline; bare `?`
prints just the newline. Unary minus added (q1 needed `-7`).
Registered `?` differences: no float literals, no `.T.`/`.F.` or NIL
printing, trailing comma rejected (Harbour prints a NIL item - probe q4).

Benchmark: the frozen three-program series (bench/RESULTS.md) was
re-run after the QOut fix with unchanged configs; see the "Post-QOut
re-run" table there. b2/b3 outputs byte-identical to Harbour. b1_int is
WITHDRAWN as a speed comparison (Harbour runs its accumulator in double,
HarbourRust in i64: different numeric work per iteration); the bounded
replacement b1b_int_bounded.hb runs integer arithmetic on both models
with byte-identical output. See bench/RESULTS.md.

Ownership across QOut items (t123-t125, neg-MODEL): `? take(v), take(v)`,
`? take(v), v` and `? take(v) + take(v)` (take consumes a String) are all
rejected as use of moved value - moves ARE applied between QOut items and
inside expressions, matching the Rust ownership contract. Harbour accepts
all three (no ownership); the difference is the registered MODEL
category, not a bug.

## Arrays (t126-t139)

Fixed-size i64 arrays with Harbour base-1 indexing (probes a1-a5).
t126-t129 and the adversarial t140/t141/t145 HB-EXACT against compiled
Harbour (-gtstd) binaries: calls as literal elements and as indexes,
evaluation ORDER of `a[i] := v` (value first, then the index - Harbour's
observed order, the same as Rust's), whole-array reassignment. t130/t144
MODEL: assignment copies (Rust [i64; N] is Copy, rustc-verified); Harbour
shares a reference. t133/t142/t143 DIVERGE-FAILMODE: a runtime
out-of-bounds index (including i64::MAX/MIN) prints the Harbour wording
and exits 1; Harbour opens an interactive error dialog and hangs (no
oracle bytes exist). These three run under the manifest `posx` kind,
which asserts the EXIT CODE on both targets, not only the message.
Constant out-of-range indexes are compile errors (t131/t132). The t02 injection negative moved
one layer up: '{' is grammar now, so the rejection comes from the parser
("trailing tokens") instead of the lexer (U+007B) - same construct, still
rejected.

## Evaluation-order fixes (t146-t149)

`a[i] := v` checks and generates value-first, then index (Harbour probe
adv2; Rust's `a[i] = v` order agrees). The checker applies moves in the
same order, so `a[take(v)] := take(v)` (take consumes a String) is
rejected as use-after-move (t149, neg-MODEL) while one-sided consumers
t147/t148 compile and match Harbour byte-exactly. `for i := a to b`
evaluates the start before the end (Harbour probe c11; Rust `a..b`
agrees); t146 pins the side-effect order byte-exactly.

## Codeblocks v1 (t150-t160)

`{|p1, p2| e1, ..., eN}` with NO captures: the value is a code pointer
(8 bytes, Copy), invoked via the built-in `eval(b, args)`. The body is a
comma-separated expression list returning the LAST one (probe c4).
t150-t156 HB-EXACT against compiled Harbour: one/two/zero parameters,
reuse inside an expression, copy-on-assignment, and extra eval arguments
evaluated (side effects run) and ignored (probes c7/c7b). Fewer
arguments than parameters are a compile error (Harbour fails at runtime
with an interactive dialog, probe c8 - t158 neg). Captures are out of
this increment (Harbour accepts them, probe c3 - t157 neg, next
increment). Bodies are integer expressions only (t159 neg); codeblock
values do not print (t160 neg). No heap is involved.

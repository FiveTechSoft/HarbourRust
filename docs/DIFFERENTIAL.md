# Differential testing vs harbour/core

Harbour is the behavior reference. Each battery case is also compiled and run
with real Harbour (pcode, hbmk2 -gtstd) and outputs are compared after
whitespace normalization (Harbour `?` right-pads numeric output; values, not
padding, are compared). Every divergence is registered here with its cause.
A divergence required by the Rust ownership model is documented as such;
anything else is treated as a bug in HarbourRust.

Reference: harbour/core @ 694428e1c12f726675b19324d62167fa77d68185,
Harbour 3.2.1dev, built locally with gcc 11.4.0.

## Run of 2026-10-25 (16 positive battery cases)

- 9 cases: MATCH (identical values both sides).
- 6 cases: Harbour REJECTS, HarbourRust accepts. Harbour error E0004 "LOCAL
  declaration follows executable statement": Harbour requires all LOCAL
  declarations before any executable statement; HarbourRust currently lets
  you declare a local where it is used. Cases: t13_if_else, t15_if_move_both,
  t20_assign, t23_while_count, t25_while_move_reassign, t31_exit_move_ok.
  Category: current PoC syntax divergence (implementer choice). It is NOT
  required by Rust ownership; keeping or dropping it is a pending decision,
  not a settled deliberate difference.
- 1 case: DIVERGE t45_for_overflow_up. When the FOR counter passes the
  int64 limit, Harbour silently continues in double precision (prints
  9223372036854776000); HarbourRust currently exits the loop. Category:
  current PoC policy (implementer choice), not a Rust-safety property -
  Rust itself panics on overflow in debug and wraps in release. Whether
  exiting is the settled policy for HarbourRust is a pending decision.

## Negative battery cases

Cases that HarbourRust rejects (ownership moves, type errors, injection
attempts) may be accepted by Harbour, whose dynamic model has no such
checks. Those are registered case by case as they are run; an acceptance by
Harbour is never passed off as equality.

## Method (reproduce)

    cp tests/tNN_test.hb /tmp/t.prg
    hbmk2 -quiet -gtstd -w0 /tmp/t.prg -o/tmp/t_hb && /tmp/t_hb
    # compare against the HarbourRust-compiled run, whitespace-normalized

## Run of 2026-10-25 (iteration 11: function parameters)

Positive cases t57-t62: 6/6 MATCH (pcode reference, values identical after
whitespace normalization).

Negative cases, verified against real Harbour behaviour:
- t63 (wrong arity): Harbour COMPILES and fails at runtime (BASE/1081
  Argument error); HarbourRust rejects at compile time. Category: static
  vs dynamic checking, a current PoC restriction, not settled policy.
- t64 (string argument): Harbour compiles and runs (dynamic typing);
  HarbourRust rejects at compile time in this increment. Category: current
  PoC restriction (implementer choice), pending string parameters.
- t65 (duplicate parameter): Harbour also rejects (E0003). Equivalent
  rejection; message text differs.
- t66 (local shadows parameter): Harbour also rejects (E0003). Equivalent
  rejection; message text differs.

Note on argument evaluation order (iteration 11): HarbourRust evaluates and
pushes arguments left to right, the same order as Harbour. This is
observable only through failing argument expressions (e.g. integer
division by zero); both sides then fail on the same argument first.

## Run of 2026-10-25 (iteration 11b: string parameters)

Positive cases t67, t68, t71, t72, t74: 5/5 MATCH (pcode reference, values
identical after whitespace normalization).

Registered divergence (model difference, agreed direction, not a bug):
Harbour copies a string when it is passed as an argument, so the caller's
variable remains usable; HarbourRust MOVES it (Rust String model) and
rejects later uses at compile time (t69, t75). Observable outputs are
identical whenever the caller does not reuse the moved variable.

Negative cases accepted by Harbour but rejected here remain as recorded in
the iteration-11 run; t64/t70 now fail earlier with "cannot infer the type
of parameter" (Harbour accepts: dynamic typing).

## Run of 2026-10-25 (preprocessor adversarial round)

t83 (case-sensitive #ifdef): MATCH (both select the else branch, value 2).
t82 (`#define MiXeD` used as `mixed`): Harbour compiles and fails at
RUNTIME (BASE/1003); HarbourRust fails at COMPILE time (undefined
variable). Category: static vs dynamic checking, same rejection class -
registered, consistent with the arity case from iteration 11.

## Run of 2026-10-25 (preprocessor F3a: commands/translates)

t84 (#command, case-insensitive keyword), t85 (capture-until-literal),
t86 (#translate call form, inline): 3/3 MATCH (pcode reference, values
identical after whitespace normalization).

## Run of 2026-10-25 (preprocessor F3b: optionals, lists, param case)

t89 (optional clause [TO <y>], absent and present): MATCH. t90 (list
capture <x,...> inserted via the plain result marker <x>, as Harbour's own
std.ch does): MATCH. Values identical after whitespace normalization.
t88 (`#define F(x) X + 1` used as `? F(2)`): Harbour compiles and fails at
RUNTIME (BASE/1003, "Variable does not exist: X" - parameter substitution
is case-sensitive, so X is NOT substituted); HarbourRust fails at COMPILE
time (undefined variable `X`). Category: static vs dynamic checking, same
rejection class - registered, consistent with t82.

## Run of 2026-10-25 (preprocessor: parenthesized-expression marker)

t91 (<(x)> pattern marker, plain result) and t92 (<(x)> result marker
re-parenthesizes): 2/2 MATCH (values identical after whitespace
normalization). t93 (unparenthesized use of a <(x)> pattern): Harbour
fails at COMPILE time with E0030 at the use line; HarbourRust rejects
with "incomplete statement" (E0020-class) - same compile-time rejection,
different error code; registered, not claimed identical.

t94 (nested optional clauses [TO <y> [BY <z>]], three use depths):
MATCH (values identical after whitespace normalization).

## Widened run of 2026-10-25 (all positive numbered tests vs Harbour)

Every positive test in the battery was built and run under Harbour
3.2.1dev (r2610242111) and HarbourRust: 52 programs compared, outputs
normalized for whitespace.

- 38 MATCH (identical values).
- 11 HB-REJECT, ALL with E0004 "LOCAL declaration follows executable
  statement": Harbour requires LOCAL declarations before any executable
  statement; HarbourRust's documented PoC policy accepts late LOCAL.
  This is the known pending policy difference (Antonio's decision), now
  quantified: t11, t13, t15, t20, t23, t25, t28, t31, t48, t52, t54.
  (First publication of this list wrongly included t17, which MATCHes;
  corrected the same day.)
- 3 DIVERGE:
  - t45/t46 (FOR bound overflow): the known pending FOR-overflow
    difference; Harbour wraps into extra iterations (double semantics),
    HarbourRust stops (i64 semantics). Category: numeric model
    difference, registered.
  - t55 (string ordering) - found here, FIXED the same day: Harbour's
    default (SET EXACT OFF) orders over the length of the RIGHT operand
    (probe b22, both directions, EXACT ON/OFF). Not a Rust-model
    conflict, so HarbourRust was aligned: hbc_str_cmp now implements the
    asymmetric rule, t55 updated and MATCHes; SET EXACT is a runtime
    setting this PoC does not have (documented in README).

## Run of 2026-10-25 (non-call #translate at statement start)

t95 (non-call #translate, statement start) and t96 (non-call #translate
with literals and two captures): 2/2 MATCH (probes b19-b21; Harbour also
applies non-call translate after its own `?` command via std.ch
chaining, which this PoC does not emulate - scoped difference).

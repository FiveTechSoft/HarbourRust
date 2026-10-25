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

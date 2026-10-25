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
  SECOND CATEGORY (explicit): for each of the 11, a hand-written
  Harbour-compatible variant (locals hoisted to the function top,
  original assignments kept in place, sibling-branch locals renamed in
  t15, per-iteration reset preserved in t48) was run under Harbour and
  compared against HarbourRust running the ORIGINAL test: 11/11
  RELOC-MATCH (identical values in those runs - not a formal general
  semantic equivalence). The variants do not hide that Harbour rejects
  the original late-LOCAL form.

Category reconciliation (disjoint, fixed to the current version):
the widened universe was 52 positive programs (94 numbered tests existed
at that moment). Of those 52: 39 MATCH (38 from the first pass plus t55
after the ordering fix), 11 HB-REJECT (all 11 also RELOC-MATCH as the
second category; t52 is one of the 11), 2 DIVERGE (t45/t46, numeric
model). 39 + 11 + 2 = 52. t95, t96 and t97 are NEW tests added after
that run (all MATCH); they are not part of the 52.
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

## Run of 2026-10-25 (string equality aligned, probe b23)

Harbour's default `=` (SET EXACT OFF) is asymmetric like the ordering:
right-operand-length comparison ("abcd" = "abc" true, "abc" = "abcd"
false, anything = "" true; <> negates). Grounded with a full matrix
(prefixes both directions, empties, EXACT ON/OFF). hbc_str_eq aligned;
t52 expectation corrected (it had been written for exact equality),
t52 MATCHes Harbour (via its LOCAL-relocated variant, see the late-LOCAL
category), and new t97 pins the matrix: MATCH. Harbour's `==` operator
and SET EXACT are not implemented (registered, not claimed).

t98 (#if relational/.AND./!/arithmetic) and t99 (#elif chain): 2/2 MATCH
(probes b24/b25).

t100 (#xtranslate, call form): MATCH (probe b26).

t101 (nested #include chain, 3 levels): MATCH (probe b29b). Circular
includes rejected by both via depth caps (F0031-class, probe b29).
Function-like arity mismatch: Harbour leaves the call unexpanded
(link-time failure), HarbourRust rejects at compile time - registered
as the same static-vs-dynamic class as t82 (probe b27).

t102 (most-specific command rule wins, both definition orders): MATCH
(probes b31/b31b; our first-defined-wins order was a real divergence,
found and fixed the same day).

t103 (void function - `return nil` - WITH parameters compiles; regression
for a codegen panic: no signature entry was recorded for void functions):
our PoC scope check (the function is never called; a void call cannot
appear in our expressions, see t104).

t104 (using a void function's result in an expression): DIVERGE (typed
model). Harbour compiles and prints NIL at runtime (verified: compiled
binary prints `3` then `NIL`; the script runner errors BASE/1081
instead); HarbourRust rejects at compile time ("returns nothing ... its
result cannot be used in an expression"). Same class as the other typed-
model restrictions.

t105 (optional result-side bracket; bound-marker-kept and no-bound-
marker-dropped forms from probes b35/b36a-d): MATCH.

t106 (kept bracket with an unbound marker leaves broken syntax): both
reject (Harbour E0030; HarbourRust "incomplete expression").

t107 (#uncommand / #untranslate: exact-match removal, stacked duplicates,
mismatched-result and unknown-rule silence, probes b32/b37a-f): MATCH.

t108 (using a command after #uncommand): both reject (Harbour E0030;
HarbourRust "statement not in the subset").

t109 (angle-form #include <file> resolved via -I, probe b38): MATCH.

t110 (angle-form include beside the source WITHOUT -I): both reject
(Harbour F0029; HarbourRust "cannot find include").

t111 (line continuation with `;`: basic, inside-string, chained; probes
b39/b39b/b39e): MATCH.

t112 (text after the continuation `;`): both reject (Harbour E0030;
HarbourRust "character not allowed").

t113 (empty #command/#translate result b40/b44; zero-param function-like
define b42): MATCH.

t114 (<{b}> match marker; b41): both reject (Harbour E0010; HarbourRust
"bad match marker"). #include with a macro name (b43): both reject
(Harbour F0030; HarbourRust "cannot find include").

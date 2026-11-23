# Bounded package A: self-VAL parameters

Clean-room MIT code. No Harbour source used. No new Harbour oracle is claimed.

Only an explicit statement `p := VAL(p)`, where p is a declared parameter,
opts that parameter into the existing owned scalar Dyn ABI. Pin evidence does
not force it back to a string. Existing VAL(Dyn), CTOD(Dyn), string concat,
argument cloning, slot replacement and cleanup code is reused. Calls without
that shape keep their old parameter inference. There is no new calling ABI.

Retyped functions mark returned numeric expressions as Dyn consumers, just
like Dyn assignments and print items, so `RETURN p + 1` preserves the runtime
float produced by VAL. This change is limited to opted-in functions.

Named limits: non-Linux, threads, macros, by-reference retyped parameters,
and Dyn-to-static-integer calls from a retyped function. The last limit avoids
the old integer-only extraction of a float-bearing Dyn. Derive an explicitly
typed numeric value or use a Dyn receiver. Indirect `n := VAL(p); p := n`,
arbitrary parameter retyping, and PCOUNT are NOT covered.

## Check
`python3 tests/param-dyn/check.py --compiler /path/to/hbc --output /new/directory`

Four exact-output Linux executions: ordinary/local numeric return, direct
numeric return, direct CTOD/concat, and caught non-string VAL. Recursive
retyped calls have depth 5. The work loop repeats 200 conversions per call,
21 calls. Every successful execution also runs with the existing post-cleanup
alloc/free DELTA guard. Required outcome is delta=0, exact output, rc=0 and
empty stderr. A missing guard or early error is not a zero. Also checks two
named limits, three target rejections and numeric/string concat runtime error.
Tests are not root-manifest rows because other targets intentionally reject.

## Interpretation
Harbour compatibility for the newly admitted retyping shape is a hypothesis
pending real-Harbour probes. Expected numeric/date values in these tests are
self-authored regression expectations, not oracle output. Memory balance is
measured through instrumented counters, not a general memory-safety proof.

Existing unrelated limitation: a Dyn numeric expression directly returned by
a function WITHOUT self-VAL, or a float-bearing Dyn passed into a statically
integer receiver, can still fail runtime extraction. This package does not
claim to repair either route globally.

## v2 dispatch and profile regressions
The initialization helper fills USER_FUNC_NAMES before computing the
persistent retyped-function set and before the first profile gate. An internal
Rust test constructs an AST containing a user VAL definition, starting from
empty and stale registries, and proves that both opt-in and persistent set stay
off. Removing the override turns them on. This is an internal dispatch test,
not proof that the parser accepts a source-level VAL definition.

In fact FUNCTION VAL is still assembler-reserved in current main. Four source
regressions pin that existing named rejection on Linux/Mach-O/ARM64/PE, without
claiming an executable override. The package does not widen reserved names.

check.py adds a fifth exact-output execution: an early string return before
conversion, with final allocation delta=0. It also checks explicit thread and
macro profile rejection. Updated totals: 5 executions with final delta=0,
2 named limits, 5 profile rejections, 4 reserved-name rejections, 1 runtime
concat error. Internal Rust tests must be run separately with rustc --test.

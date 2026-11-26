# ValType over floating literals and F64-returning calls

Original MIT fixtures. This increment evaluates literal floats and calls inferred as F64 through cg_f64_load, then returns N. Calls execute once, including their output and effects. Arithmetic expressions beyond folded literals and integer-returning calls remain rejected. No storage, RC, object lifetime or arbitrary-expression expansion.

Measured against Harbour core 694428e1c12f726675b19324d62167fa77d68185, Linux GTSTD: 7 cases in five modes, 35 exact stdout/stderr/rc triples. Modes: native, external-as, no-vas-arrays, no-escape-analysis, no-prune. Instrumented normal cases; TRY throw case uses expanded BEGIN SEQUENCE / RECOVER oracle syntax. Owned-string arguments use string concatenation in the callee to constrain inference. An earlier Len(s) attempt inferred a dynamic array and failed compilation in all modes; retained evidence, not a parity pass or new compiler guard.

Four current compile limits: actual LOCAL float @ borrow and codeblock capture, integer-returning call and runtime arithmetic. First two preserve generic pre-existing limits. No claim that Harbour rejects them.

Regression: 155 float triples (50 local STATIC, 65 module store, 40 reads), 20 prior ValType-variable triples and 40 Bool triples. Three strict-zero controls insert DELTA_GUARD after cleanup into emitted assembly: expected rc99 and DELTA=0, not production runtime parity. Rust 118 passed. GTSTD 88 classified outcomes, including registered fatal differences and compile limits, not 88 oracle-exact passes.

Negative differential: 618 sources on Linux and Windows unchanged. This is not 618 clean rejection passes: Linux 609 rc1 plus 9 historical rc0; Windows 618 rc1, stale expected-substring debts retained. Upstream census: 1041 sources, 65 admitted, unchanged diagnostics versus previous compiler. Neither check asserts full Harbour compatibility.

Parked: global RC/object lifetime, numeric-array division, arbitrary F64 expression ValType, original initexit PUBLIC/macro/STATIC-string boundary, fatal-div0 EXIT/cleanup difference. ASort and and_or/errsys are outside this increment.

No push, workflow, publication, binaries or objects. New commits only. See review state, exact commands/cwd/rc/stdout/stderr, compiler hashes and detached-base apply-check in the review archive. Independent full checkout build and scoped replay recorded separately if present.

# Module STATIC objects, first increment

This increment admits `STATIC o := NIL`, then assignments fixing one class
through a direct constructor (`o := T()` or `o := T():New()`). It does NOT
close scalar retagging: `STATIC o := 0; o := T():New()` keeps its named
rejection. Effectful constructor initializers are not valid Harbour STATIC
initializers, so they are not invented here.

Every function reads the canonical module pointer, not a frame snapshot.
Rebind retains the new object before releasing the old object. Local aliases,
parameters and returns use ordinary object ownership. Module cleanup releases
the canonical owner once. Null is an observable NIL, including ValType U;
a live instance is ValType O. The first class is fixed syntactically, not
guessed from member names. Multiple constructor classes are a named limit.

Run check.py with --compiler, --hbmk2, --tree, --output and optional --wine.
The gate has21 assertions:6 fresh oracle/raw target-pin comparisons,
6 named rejections (valid Harbour),6 measured memory comparisons at
N=1/500/1000, and3 explicit null-receiver catch paths. Each memory comparison
executes the real constructor/alias/selfassign/return/NIL-release/DATA path
and its control. Exact integer bound2 is the object pool. String DATA bound3
includes the retained string template. These are measured controls, not a
zero-leak claim or an exemption. Failures before the counter, missing DELTA,
unexpected rc/stderr or wrong stdout all fail closed.

Null DATA read/write and method sends fail with the description string
`Object access on NIL`, not a crash. This is the runtime's declared string
error model, not Harbour's Error object or its genCode/subCode interface.
Uncaught forms exit1; caught forms continue. @ borrows, object container/block
captures, effectful receiver arguments/DATA RHS and threads are named limits.
Existing function-local STATIC and module scalar/string/array paths retain
their own contracts. Alias-based calls or other object patterns outside this
measured subset retain the compiler's prior object limits.

Four meaningful positive programs join the native manifest. The Linux/Wine
pins are copied from actual target output and protected with -text. The native
runner inventory is1234+56=1290; ARM64 has no named rejection, Intel keeps5.
Local Mac checks are emission-only unless a report explicitly says native.

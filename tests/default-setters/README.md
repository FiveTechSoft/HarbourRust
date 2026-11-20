# Scalar default setters, work in progress

Own MIT implementation and probes; external Harbour executable oracle only.

__defaultNIL(@slot, fallback) changes only a NIL slot. hb_default(@slot,
fallback) changes a slot whose Harbour category differs from fallback.
Both evaluate fallback eagerly, then inspect the current slot, after any RHS
effects. Integer/F64 are category N without converting the selected payload.
Both return NIL. Selected strings have independent ownership.

Bounded to ordinary Linux without threads or macros, ordinary Dyn local slots
and scalar fallback values. Parameter inference from these builtins uses Dyn;
by-value and omitted parameters can be used as local slots. Passing a Dyn
caller slot through @parameter retains the existing caller ABI rejection.
Typed, byref-received, static and read-only slots remain named build limits.
Date, arrays, hashes, blocks, references and other Dyn-producing fallback
expressions remain named limits. Dyn-held unsupported containers produce an
explicit fatal limit after RHS effects. This is not a catchable Harbour error
or container support. Borrowed container payloads are not freed by scalar
snapshot cleanup.

check.py:34 unchanged own sources,68 int/ext exact rc/stdout/stderr comparisons
against freshly executed external Harbour. Base build rejection is separate.
safety.py: three instrumented lifetime modes,10000 iterations with10000 caught
nested RHS failures, allocation delta0 after warmup;12 profile and26 shape
limits. diagnostic.py:16 runtime scalar-limit cases across two APIs, slot or
fallback array, int/ext and separate/merged streams. mutants.py: five Rust and
PRG build-valid mutants, runtime0 divergence required; no rejection, timeout
or OOM is accepted as detection. Controls for memory faults are instrumentation,
others compare to fresh Harbour. Forced equal-length string cache reuse is
required to expose the borrowing mutant.

No Bin/Cmp or statement/error-call trace emission changes. Existing trace
helpers and PROC metadata are untouched. No workflow, manifest, expectations
or external PRGs changed. Broad regression and postcommit builds still pending.
Twenty pinned originals whose first errors are these setters were tested in
scratch: zero acceptance changes; first-error movement is not an unlock claim.

# Monomorphic Date LOCAL and inline assignment

Own MIT implementation and synthetic probes. Harbour is an external executable oracle only. No external patch is used.

Ordinary Linux without threads admits inline `:=` when the RHS and destination already have Date type. Date remains its existing 8-byte immutable value. The existing scalar store/emitter is reused, with no Dyn Date tag or new ownership path.

A bare top-level LOCAL may be lowered to an empty Date initializer only if its first lexical mention after declaration is an unconditional top-level statement assignment or a direct inline assignment item in PRINT, with Date()/SToD()/CToD() as RHS and no self reference. This initial value is unobservable: the first mention stores the actual value before a read. The existing exhaustive lexical mention predicate includes nested indices, hashes, code blocks and sends. A by-reference use anywhere in the function or any macro program disables this narrowing. Unknown first-mention shapes, nested declarations and branch/loop/TRY first stores do not qualify. Existing Date type checks reject later NIL/numeric retyping.

This does not add Date in Dyn, Date variant parameters, general Date arithmetic inference, byref Date stores, Date comma-list/discard results, whole-array IIF, or other target profiles. Existing monomorphic Date parameters already pinned by their consumers can use inline stores by value. No statement or error-call trace emission, Bin/Cmp implementation/emission, PROC metadata, workflow, manifest or expected fixture changes.

Run:

    python3 tests/date-local-inline/check.py --compiler ./hbc --baseline /previous/hbc --hbmk2 /external/hbmk2 --output /new/exact
    python3 tests/date-local-inline/safety.py --compiler ./hbc --output /new/safety
    python3 tests/date-local-inline/mutants.py --compiler ./hbc --rustc /rustc --hbmk2 /external/hbmk2 --output /new/mutants

check.py has 13 sources, each int/ext compared byte-exactly in rc/stdout/stderr against fresh Harbour. Safety has 3 instrumented modes, 1000 repeated stores and 1000 failed RHS catches with the prior Date retained, warmup then allocation delta zero; 5 excluded profiles and 16 shape rejection controls. Some shape rejections are pre-existing parser/type limits and are not proof that narrowing reached its guard. Three Rust-build-valid mutants separate PRG build rejection from runtime divergence. Ignoring the early lexical observation yields D instead of Harbour U before the first store.

The captured corpus is not 1041 standalone applications. The measured prototype has zero new accepted files and one advancing first diagnostic in tests/dates.prg. That file still fails at another bare Date producer shape. No full Date-program support is claimed.

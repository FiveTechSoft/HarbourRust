# Eager scalar hb_defaultValue, ordinary Linux

Own MIT implementation and probes, external Harbour executable oracle only.
No Harbour source or libraries are used for the implementation.

`hb_defaultValue(value, fallback)` evaluates both arguments left to right. It
keeps an independent snapshot of the first value when its Harbour category
matches the fallback; otherwise it returns an independent fallback snapshot.
Integer and F64 both count as N without converting the selected integer to F64.
False, zero and empty strings are values, not a request for a fallback. The
input slot is not changed. String snapshots survive source replacement and
forced cache reuse. Both unselected snapshots and snapshots held across a
failed fallback expression are released.

This increment is ordinary Linux without threads or explicit macro syntax.
It accepts typed I64/F64/logical/string arguments, NIL, Dyn variables and nested
hb_defaultValue calls. The result is an owned scalar Dyn. Date, arrays, hashes,
blocks, objects, references, mixed-numeric locals and other Dyn-producing
expressions keep named build limits. A Dyn variable can carry an unsupported
kind at runtime: both argument effects happen, scalar snapshots are released,
then an explicit fatal scalar-only limit is reported. That limit is not a
Harbour error, not catchable-error parity and not container support. Borrowed
unsupported container payloads are never freed by the scalar cleanup path.

`__defaultNIL` and `hb_default` are still unsupported. Their by-reference
mutation and inference must not be replaced with this value-returning API or a
lazy IIF. This increment does not promise to unlock the 23 corpus files whose
first error was in the broader defaults family.

Run:

    python3 tests/default-value/check.py --compiler ./hbc --baseline /base/hbc --hbmk2 /path/to/hbmk2 --output /new/exact
    python3 tests/default-value/safety.py --compiler ./hbc --output /new/safety
    python3 tests/default-value/diagnostic.py --compiler ./hbc --hbmk2 /path/to/hbmk2 --output /new/diagnostic
    python3 tests/default-value/mutants.py --compiler ./hbc --rustc /path/to/rustc --hbmk2 /path/to/hbmk2 --output /new/mutants

29 own sources give 58 exact int/ext rc/stdout/stderr comparisons. Three own
exception probes use an explicit oracle-only adapter from TRY/CATCH/END to
Harbour BEGIN SEQUENCE WITH / RECOVER / END SEQUENCE; both source hashes and the
adapter flag are recorded. The other 26 sources are unchanged between compilers.
The adapter is test syntax, not a product implementation or copied source.

Three instrumented modes run 1000 loops and 1000 caught nested fallback errors
per Work. Warmup then allocation delta zero; forced string-cache reuse, return,
self-copy, F64, nesting and discard are exercised. Six profile and eleven shape
controls are distinct from oracle parity. Eight fatal-limit cases cover both
operand positions, int/ext, separate/merged streams, and successful Harbour
execution proving that this is a compiler limitation.

Four Rust-build-valid counterfactuals are detected: selecting fallback on a
matching kind, failing integer/F64 kind unification, borrowing the first string
rather than copying, and leaking the unselected fallback snapshot. Runtime
output differences and allocation-delta differences are recorded separately
from build rejection. Build failures and timeouts never count as catches.

No Bin/Cmp implementation or emission, statement/error trace emission,
trace_location/link/unlink/finalize_trace, PROC metadata, workflow, manifest or
old expectation is edited. Existing callers emit the previous code unchanged.

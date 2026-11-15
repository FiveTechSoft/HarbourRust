# Literal numeric argument borrow fast path

Left/Right/SubStr skip their retained-source snapshot ONLY when every numeric
argument is an Expr::Int literal after parsing. SubStr requires both start and
count when count is present. Other expressions, including variables, calls and
unary arithmetic not represented as Int, retain the previous snapshot path.
Fresh owned source temporaries are released after the slice result is created.

check.py compares baseline/candidate against fresh Harbour694428e gtstd for
borrowed/owned/nested/empty/NUL inputs, retained-source mutation and normal
variable counts. It runs ELF and optional Wine PE, normal/instrumented, plus
post-owner hb_memcheck wrappers requiring final0. Fallback fixture assembly must
be BYTE-IDENTICAL baseline/candidate on both targets with/without instrumentation.

Limits: literal-only no-effect proof, not general purity or alias analysis.
No deletion of the snapshot for dynamic/effectful later arguments. Existing
owned TRY error-path cleanup limitation is not solved. No ABI, helper runtime,
string cache, Unicode/codepage or metadata-proof change. No native Windows or
Mac execution claim. Timing covers whole loops, not intrinsic-only throughput.

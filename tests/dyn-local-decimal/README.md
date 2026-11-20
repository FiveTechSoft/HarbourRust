# Decimal stores into parameter-copy LOCALs, bounded Linux increment

Own MIT implementation/tests. No contributed diffs used. P01/P02 are optional
unchanged input programs, Harbour is only an external executable oracle.

A copied parameter may initially have I64 storage. A later literal decimal
store, or variable +/-/* decimal literal, now seeds its existing owned Dyn
storage contract on ordinary Linux. Existing NumLocal detection wins first:
this is not a general promotion of numeric locals or a new return ABI.
Only pre-scan/storage selection changes. No edits to Bin/Cmp type or emission,
move handling, trace metadata/finalization, renderer or terminal code.

Scope is structural, not inferred from a late THREADS flag: scan the entire
program before the semantic fixpoint and exclude any hb_thread*/hb_mutex* call,
including later functions/methods/blocks. This only controls new admission and
does not alter existing thread mode. PE/Darwin/LLVM/threads keep previous limits.
Named rejections of NumLocal return ABI and byref storage remain.

Before editing, direct return arithmetic and an explicit bare Dyn local passed
exactly, while an initialized parameter copy followed by decimal reassignment
rejected. Even a constant decimal store without any Bin rejected. This isolated
storage selection independently of the reserved arithmetic/comparison arms.
An initial broad hint was narrowed to the documented forms. The late THREADS
flag alone admitted a function before Main's thread start was typed; the whole
program structural profile proof replaces that failed prototype.

check.py:19 sources including P01/P02, two assemblers, exact rc/stdout/stderr.
safety.py:three instrumented modes, Work1000 normal iterations plus1000 caught
output-argument exceptions per call. Warmup then delta allocations0. Seven
build checks:five excluded profiles and NumLocal-return/byref named limits.
These instrumentation and rejection checks are not Harbour oracle claims.

The1041-corpus first-error counts are not unlock promises. The first prototype
had no corpus state/firstdiagnostic changes despite closing P01/P02. Recheck
final evidence before relying on any corpus-impact number.

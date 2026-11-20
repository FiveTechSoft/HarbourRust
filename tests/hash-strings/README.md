# Hash strings, bounded increment

Own MIT code and probes, no external diff read/applied/copied. Harbour is a
separate executable oracle. P07 remains unchanged optional external test input.

New admission: literal-string hash values, ordinary Linux without threads, via
literal map initialization/reassignment, indexed write and hb_HSet. Indexed
literal writes require literal/variable keys, not effectful keys. Direct owned
string producers/variables and numeric keys keep their existing rejection.

Existing accepted Dyn string values previously aliased storage. Mandatory
pre-fix probe forces the owner's string-cache block to be reused: baseline
prints BAD-VALUE twice, Harbour prints OLD-VALUE then BAD-VALUE. Equality before
reuse and allocation delta zero did not prove ownership. The fix copies string
payloads before replacing old entries. Drop paths cover overwrite, delete,
position delete, clear, final free and fill. Copy/clone/merge retain independence.

HValues numeric arrays retain cell-write and FOR EACH support. Widening
HValues to general Dyn arrays rejected two existing positive tests, so that
prototype was rejected. String HValues now takes an explicit runtime limit
before allocation. Its own diagnostic uses the existing raw writer and fatal
trace exit, with the existing early console-close boundary on native Linux.
No existing trace/finalizer/renderer functions are edited. Separate and merged
stdout/stderr probes cover both assemblers on Linux and Wine. This limit is
not an oracle-compatible operation or a catchable Harbour error claim.
diagnostic.py records the baseline and candidate channels side by side.
mutants.py checks clone, drop and literal-admission counterfactuals separately.

Current focused gate: 21 sources, 42 exact rc/stdout/stderr comparisons, internal
and external assembler. Lifetime workload: 1000 loops per Work, warmup then zero
net allocations, including1000 TRY/CATCH unwinds per Work; clone/copy/merge/overwrite/delete/fill/free and literal values.
Build-profile and rejection probes remain separate from runtime oracle claims.

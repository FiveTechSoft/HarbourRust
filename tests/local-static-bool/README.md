# Function-local STATIC logical storage

Original MIT. Literal logical local STATIC declarations register fixed Bool
storage under the existing function-qualified persistent label. Existing
RefI64 load/store routes carry 0/1. No new RC, alias, allocation or retag route.
ValType of persistent logical variables now recognizes Bool behind RefI64,
for module and function-local storage (was incorrectly N).

40 exact triples,8sources x5modes: persistent toggling, independent module/two
function identity, INIT/Main/EXIT+QUIT, recursion, by-value copies/ValType,
method-local storage and module ValType control. The eighth is intact t1613
as it stood before this change: logical STATIC in INIT, now oracle-exact.
Original copied to intact-t1613.prg; historical negative fixture now tries an
integer retag and rejects. Its manifest expectation now type-mismatch on Linux;
Windows still rejects the profile earlier, so no cross-target clean claim.
155 previous local/module float triples exact.11 own limits plus2platform
checks. Inline :=,++,@,counter and captured block remain rejected. Retag int,
float,NIL,string rejected. Windows/LLVM share the ordinary-Linux diagnostic.
Thread guard still says module but includes local Bool; macro bind rejects.

Strict-zero3 with actual local Bool writes plus persistent owned cleanup,
GTSTD88,Rust118.618 historical negative sources are differential: Linux609rc1
and9rc0,Windows618rc1. Existing nine Linux admissions unchanged. Only t1613
changes vs base (Linux expected false->true; Windows remains earlier rejection).
Census1041/65 compile admissions unchanged,1guard-wording diagnostic change
initexit.prg,not closed. No full Linux manifest/perf/FullLLVM/fatal-unwind fix.

First own attempt retained: ValType returnedN in copy fixture; fixed toL and
module control added. Inline assignment was attempted and rejected, preserved
as a scope limit, not promoted. Builds succeeded. Initial25/35 is not a green.
No independent rebuild claimed in this primary package.

# Local STATIC shared array literals

Own MIT. Local STATIC accepts recursive constant arrays of i64,string,logical,
NIL and empty arrays. Slots register as existing Dyn tag16 shared arrays with
function-qualified process storage,using existing module array init,sweep,
cell and borrow guards. No new global RC model. Ordinary Linux only.
15 exact triples:3sources x5modes. Repeated calls,independent same-name slots,
mixed cells,nested arrays,empty growth.6compilelimits+3strict finalzero.
First emptyarray fixture exposed DArrNew parser representation and failed;
DArrNew registration and admission fixed,and fresh entire15matrix passed.
No original closure:statics.prg now reaches module string capture in a closure,
which remains rejected by existing owned/container guards. No silent capture
or detached lifetime claim. INIT/EXIT,floatinitializers,compound cell ops and
AIns remain named boundaries. Black-box oracle https://github.com/harbour/core.git
commit694428e1c12f726675b19324d62167fa77d68185,no implementation copied.

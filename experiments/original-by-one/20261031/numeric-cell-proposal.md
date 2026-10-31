# Numeric-cell promotion study for original tests/arrayidx.prg

PROPOSAL ONLY. No compiler, runtime, ABI or ownership mutation.

## Source-grounded requirement

The unchanged original writes and returns integer updates, then0.80(/=),
3125.00(^=),1.00(%=). Existing storage:fixedArr(n)8*n bytes, onlyI64;
Dynleaf16bytes tag/payload(integer/logical/NIL);F64scalar16bytes holds value
anddecimal/width metadata. Existing LLVM rejectsF64 and dynamic cells;default
hasF64 arithmetic/printing and owned dynamic arrays. New numeric cells must
not be admitted into old helpers by changing only a type-check.

10 fresh independent Harbour oracles in numeric-cell-oracles10.json:
- Updating one cell toF64 does not convert other cells:integer1 prints1,
  updated2/5prints0.40,bothValTypeN.
- Reassigning7 then7.00 must restoreinteger output then2decimal output.
- ASizegrowth createsNIL;float remains0.20,othercell4.5keeps1decimal.
- Passing array and aliasassignment exposemutationinHarbour. This observation
  is NOT permission to change currentRustmodelcopy/move/borrow rules.
- Arrayreturn preserves0.80;indexevaluatedoncebeforerhs.
- Overflow may turnintegerintoF64 inHarbour;currentI64wrapping/overflow policy
  must stay explicit,not silently pretendgeneralnumericpromotion.
-1.2300+2keeps4decimalplaces;multiplying1.20produces3.876000.
-Integer%=0prints0underreference;divisionzero is separateerror contract.

## Candidate A: bounded new internal numeric-cell type

Investigate a distinct NumericCellArray(N), not reinterpretArr/DArr.
Initial unimplemented layout proposal:24bytes/cell,8tag(I64/F64/NIL),8payload
(integerbitsorIEEEbits),8metadata(existingF64width/decimalword). Keepmetadata
separate instead of inventing a lossy bitpack. This preserves fullI64 range and
floatprovenance;tagdispatchread/arithmetic/store;I64storeclearsoldmetadata.
Static prescan selects newstorage only for arrayroots whosewrites maydeliverF64;
integer-onlyarrayprograms retain existing8byte cells,codegenandperformance.
Floatpromotion cannot mean turning everycellintoF64:that changesoutput of
untouchedintegers and losesprecision above2^53.

## Ownership, aliases, calls and returns

First bounded route could keep local-only numericcellarrays,explicitlyrejecting
passing/returning them. It could complete localarrayidx without externalABIchange.
But it is NOT generalarraycompatibility and would need its own scopedcontract.
No referencecount,sharedpersistentmutablealias orcycle support isintroduced.
ExistingArrCopy andDArrMove/temporaryexclusiveborrows remainunchanged.
Later calls/returns require distinct signature/typeinference,sizes/alignment,
callee/returnstorage andownershipproofs;oldArr/DArrhelpers cannot receive newcells.
No cross-languageABI extension orC/RDDbridge is needed for the local-only route.

## Backends and tests before any activation

Default:per-cellload/store,existingF64metadata/arithmetic/printer reuse via typed
adapters,not treating24byte cells asDyn16. Bounds before memoryaccess;index once,
RHS once;hold root/slot safely acrosscalls;aliasingandrootresize duringRHS must be
rejected orresolved withoutdanglingpointer. No hidden copy of effects.
LLVM currentlyhasnoF64locals/signatures/runtimeadapters. It needsF64lowering and
metadata plus correctinteger/floatdispatch,or explicitnamedrejection. Do notlabel
arrayidxLLVMequivalent afterdefaultonlypass. ExistingI64fixedarrayIR staysunchanged.

Required gates:originalarrayidxbytes/exitexact,neworder/bounds/overflow/NIL/rewrite
oracles,moved/borrowedrootnegativecases,allocfreebalance ifheapused,default+LLVM
oldbatteries,14controloriginalsexact,268x4diagnostics,independentremoteclosure,
thenbytes/speedvsRustwithmatchingmetadata/checks. Noactivationauthorizedbythis
proposal;Aisunderresearch,Bgeneralheterogeneouscells/RC/cyclesnotopened.

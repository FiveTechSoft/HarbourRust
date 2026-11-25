# SET FIXED console numeric display, ordinary Linux

Own MIT. SET FIXED ON/OFF and Set(2[,literal logical/NIL]) use runtime state.
Set returns previous logical state. Standard _SET_FIXED macro is selector2.
Only ordinary Linux without macros/threads/LLVM is admitted. Dynamic values
and other argument kinds remain build limits. User macro precedence remains.

Print-only float entries replace the output decimal count with SET DECIMALS.
Integer print entries append that many zeros without converting through f64.
Item slots and metadata remain unchanged. Str() uses its separate owned
formatter from unchanged F64_HELPER, so Str() is unaffected. State defaults
OFF. QOut/QQOut,OutStd,OutErr and shared Dyn numeric entries are covered.
Private stderr clones rename the new local labels too.

20 exact triples:4 sources times5modes. Floats/negative/integers/mixed numeric
locals/integer array cells/date parts,DECIMALS0/4/6,logical oldstate,NIL no-op,
OFF restoration and Str() preservation.6compilelimits+3strict finalzero.
GTSTD exits88,Rust118. No full LLVM/performance/full original replay claim.

Intact upstream str.prg compiles now, but is NOT an exact closure:two lines
for10^20 show an existing finite-float field overflow mismatch (digits instead
of Harbour asterisks),including the FIXED-OFF half. Failed original evidence
is retained. This increment does not alter global Str() to hide that mismatch.
No Harbour implementation or cambio.diff copied. Black-box original source:
https://github.com/harbour/core.git commit694428e1c12f726675b19324d62167fa77d68185.

Correction: selector2 is _SET_FIXED; selector1 is _SET_EXACT and is not
implemented by this change. The prior package incorrectly aliased FIXED to1.
Corrective commit changes macro/checker/codegen/typeinfer together and adds
an explicit numeric-selector2 fixture plus selector1 rejection. Fresh review
compiler93f163ff:25exact triples,7compile limits+3strictzero. The intact
str.prg now passes5modes on that same compiler with the separate overflow
fix included. Earlier package identities and selector1 claims are superseded.
Three failed corrective builds remain failures;after verified old raw archive
retirement,the review build completed rc0 in11.5s. No full regression claim.

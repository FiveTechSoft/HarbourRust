# LLVM inline assignment to existing I64/logical locals

Own MIT backend increment. Existing frontend-checked Expr::Set evaluates RHS
once,stores to an existing local slot,and yields that new scalar value. Logical
result classification follows RHS including nested inline assignment. Discarded
assignment uses the same lowering;lazy branches retain conditional effects.
No byref/string/float/array/Dyn storage ABI or new frontend admission.

Fresh gate10:2sources xnative/traced/untraced=6exactHarbour outputs,4named
frontend rejection checks(float/string inline assignment xLLVMmodes). Nested
stores,logicalprint/condition,sequenceeffects,callorder,lazyIIf/and/or,discard.
Initial gate found logical assignment printed1instead.T.in LLVM;isbool corrected,
full gate rerun. Initial mismatch raw retained separately,not countedPASS.
Rust113;Python66=64pass2skip;LLVM206sources618nativebackendexact(notHarbour);
Linux1185;618negativesx2targets unchanged;census1041/60same;57originals
285exact+55zero+2knownDELTA2separate. No new upstreamoriginal admitted.
No fullPEemission/Macruntime/performance/allhistorical-suite claim.

No ownership/RC/ASort/numericarraydivision/workflow/push/publication/rebase.
JulioPonceMITexamples specifications only,no suppliedimplementation/cambio.diff
copied. Raw commands/cwd/source/run outputs and compilerhash retained.

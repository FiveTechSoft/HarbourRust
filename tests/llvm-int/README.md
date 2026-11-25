# LLVM Int on already supported I64 scalar expressions

Own MIT bounded increment. Int evaluates its scalar argument exactly once and
returns the existing I64 result unchanged. Integer locals,arraycells,arithmetic,
lazy IIf,calls,sequences,and checked prefix/postfix increments use existing
lowering. No float/Dynconversion,newnumericABI,ownership or frontend admission.
Abs is deliberately not included:minimumI64 promotion needs separate evidence.

Fresh Harbour gate10:2sources xnative/traced/untraced=6exact,plus4namedlimits
(floatliteral and Val-returnedfloat rejected in both LLVMmodes). Zero,negative,
max/minI64,loopvalues,callorder,sequenceeffects,arrayread,lazybranch,mutations.
Rust113;Python66=64pass2skip;LLVM206sources618nativebackendexact(notHarbour);
Linux1185;618negativesx2targets unchanged;census1041/60unchanged;57originals
285exact+55zero+2knownDELTA2separate. No new upstreamoriginal admitted.
No fullPEemission/Macruntime/performance/allhistorical-suite claim.

JulioPonceMITexamples remain specifications only,no suppliedimplementation or
cambio.diff copied. NoRC/objectpolicy/ASort/numericarraydivision/workflow/push/
publication/rebase. Raw commands/cwd/input/output/rc retained.

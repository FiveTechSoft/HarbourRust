# Logical literals in numeric preprocessor conditions

Own MIT black-box increment. #if/#elif accept.T./.F.(case-insensitive) as1/0
and tokenize dotted logical operators independently even when adjacent,for
example.T..AND..NOT..F. Macro-expanded logical literals use the same scanner.
Existing eager condition evaluation is retained:even an apparently unneeded
logical arm containing division by zero rejects,as measured in Harbour.
&& remains a reader comment,not a new logical operator.

Fresh gate15=9native byte-exactHarbour outputs+6rejections(3zero-division
positions xLinux/PE,preserving oldoutput). Rust113;Python66=64pass2skip;
prior definedgate24;LLVM206sources618nativebackendexact,notHarbour;
Linux1185;618negativesx2targets unchanged;census1041/60unchanged;57originals
285exact+55zero+2knownDELTA2separate. No new upstreamoriginal admitted.
No fullPEemission/Macruntime/performance/allhistorical-suite claim.

JulioPonceMITexamples are specifications only,no suppliedimplementation or
cambio.diff copied. NoABI/ownership/RC/ASort/numericdivision/workflow/push/
publication/rebase. Newcommits only,rawsource/commands/cwd/results retained.

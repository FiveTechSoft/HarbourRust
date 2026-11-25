# Left associativity of preprocessor multiplication/division/remainder

Own MIT bug fix. parse_term previously recursed for RHS,grouping equal-precedence
*/% operators to the right. Parse one atom for each RHS,loop left-to-right.
No change to runtime division,numeric-array policy,operator precedence or
parenthesized expression grouping. Fresh Harbour confirms24/4/2=3,20/6*3=9,
20%6*3=6,2*3/4=1;unary negative and explicit parentheses covered.

Fresh gate15:9byte-exactHarbournative outputs+6closedreject controls(divide/
remainder/parenthesizedzero xLinux/PE,preserving oldoutput). Rust114,
Python66=64pass2skip;Linux1185;618negativecasesx2targets unchanged;census1041/
60unchanged;57original285exact+55zero+2knownDELTA2. Current complete LLVM
manifest1185scan:355admittedx3=1065exact(native/traced/untraced),830cleanreject.
Manifest comparisons NOT fresh Harbour. First LLVMmanifest attempt interrupted
by combined-command timeout before results;fresh separate run completedPASS.
No new upstreamoriginal admission/fullPEemission/Macruntime/perf/allhistorical.

JulioPonceMITexamples specifications only,no suppliedimplementation/cambio.diff
copied. NoABI/ownership/RC/ASort/workflow/push/publication/rebase changes.

# Shift operators in preprocessor conditions

Own MIT observed increment. #if/#elif << and >> operate on i64 bitpatterns,
sharing the left-associative level of &|^,below arithmetic and above comparisons.
Right shift is arithmetic. Count uses low6bits,including negative/large values;
negative does NOT reverse direction. Explicit wrapping shifts avoid Rust panic
at count64and beyond. Values bit63,min/maxsigned,negative masks measured.
This is pinned host Harbour behavior,not a portability claim for every toolchain.
Runtime arithmetic/numeric-array policy untouched.

Gate22fresh=16native byte-exactHarbour outputs+6closeddiv0rejectcontrols x
Linux/PE. Counts0/63/64/65/1000/negative/minI64/allbits,operator precedence,
left association,explicit parentheses. Rust116;Python66=64pass2skip;Linux1185;
negative618x2targets unchanged;census1041/60same;57original285exact+55zero+
2knownDELTA2separate. FullLLVMmanifest1185scan355admittedx3=1065exactmanifest
(notfreshHarbour),830cleanreject. No new upstreamoriginal admitted.
No fullPEemission/Macruntime/performance/allhistorical suite claim.
NoABI/ownership/RC/ASort/numericdivision/workflow/push/publication/rebase.
JulioPonceMITexamples specifications only,no implementation/cambio.diff copied.

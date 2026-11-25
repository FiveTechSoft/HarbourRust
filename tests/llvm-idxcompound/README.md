# LLVM indexed compound updates on fixed I64 arrays

Own MIT increment: existing a[i] +=/-=/*= e node now lowers in LLVM.
Index evaluates once first,bounds before RHS,RHS once,then cell load,
operation/store,return new value. Nested writes affect the outer old operand,
as measured in Harbour and existing native backend. No new frontend syntax,
array representation,ownership,RC or numeric-division policy.

Own gate13rows:6byte-exact outputs (2sources x native/traced/untraced),
3bounds-before-RHS checks,4named-limit rejections. Error diagnostics are NOT
byte-exact. Oracle-only error handler makes the bounds test deterministic;
it adds no change to the tested expression,whose copied input/hash are saved.
Division and dynamic-array update remain frontend rejections. Values,effects,
index mutation,same-cell nested updates,lazy IIf,discarded loop updates covered.
Unchecked wrapping I64 arithmetic matches existing LLVM/native subset; no
claim of Harbour integer-to-double overflow promotion or checked-I64 mode.

Fresh Rust118,Python64pass2skip,Linux1185,negative618x2targets unchanged;
57original285exact+55zero,2knownDELTA2separate;18frontiergates282mixedrows.
FullLLVMmanifest1185scanned,356admitted x3=1068exact to manifest,829reject,
one new LLVM admission,not freshHarbour. Scan resumed after execution timeout
by replaying saved command/rc/stdout/stderr only for completed steps; resume
script included. Own final gate freshHarbour. Earlier failed experimental
runs excluded from evidence claims. No fullPE/Mac/performance/allhistorical
claim. Census not rerun:frontend source unchanged. No push/publication/rebase.
Julio Ponce MIT examples specifications only,no implementation/cambio.diff copy.

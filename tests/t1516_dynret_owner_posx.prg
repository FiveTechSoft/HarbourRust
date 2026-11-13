// ains P2 stage 1 closure (independent-review blocker on 6896c79f): a
// Dyn-held ARRAY may not escape through a return - the caller would
// alias the owner and the callee epilogue would free it under him
// (SIGSEGV before this closure). Registered runtime failure: rc 1, the
// owner dies with the process. Dyn array params/returns stay OUT of
// scope; scalar Dyn returns are unaffected.
procedure main()
local y := make()
? ValType(y)
? Len(y)
return
function make()
local x
x := { 1, "canary" }
return x

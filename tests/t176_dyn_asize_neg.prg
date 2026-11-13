// DIVERGE-FAILMODE: Harbour dialog hangs; clean message + exit 1
function main()
local a := {}
AAdd(a, 1)
ASize(a, -1)
return nil

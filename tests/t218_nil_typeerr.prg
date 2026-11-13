// NIL in arithmetic: Harbour raises a type error whose interactive dialog
// cannot be probed headless; the PoC prints and exits 1 (registered
// failure mode, same error condition - not a compat success).
function main()
local a := {}
local b := NIL
AAdd(a, NIL)
b := a[1]
? b + 1
return nil

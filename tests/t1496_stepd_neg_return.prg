// ains 1b step (c)-next: independent fixture, not Harbour source
// Returning the raw-cell iif stays rejected.
procedure main()
f()
return
function f()
local a := {1,"x"}
return iif(hb_isnumeric(a[1]), hb_ntos(a[1]), a[1])

// ains 1b step (c)-next: independent fixture, not Harbour source
// The raw-cell iif is an OUTPUT-ONLY shape: storing it stays rejected.
procedure main()
local a := {1,"x"}
local x := iif(hb_isnumeric(a[1]), hb_ntos(a[1]), a[1])
return

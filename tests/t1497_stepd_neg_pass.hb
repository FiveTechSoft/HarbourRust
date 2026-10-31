// ains 1b step (c)-next: independent fixture, not Harbour source
// Passing the raw-cell iif as an argument stays rejected.
procedure main()
local a := {1,"x"}
? len(iif(hb_isnumeric(a[1]), hb_ntos(a[1]), a[1]))
return

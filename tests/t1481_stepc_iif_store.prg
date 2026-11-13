// ains 1b step (c): independent fixture, not Harbour source
// Harbour: compiles, prints nothing, rc 0. (c) design: named compile-time
// rejection - registered conservative divergence.
procedure main()
local a := {1}
show(a)
return
procedure show(s)
local x := iif(hb_isnumeric(s[1]), hb_ntos(s[1]), valtype(s[1]))
return

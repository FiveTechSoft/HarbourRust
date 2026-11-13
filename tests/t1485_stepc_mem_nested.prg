// ains 1b step (c): independent fixture, not Harbour source
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {5,"q"}
show(a)
return 0
procedure show(s)
?? iif(hb_isnumeric(s[1]), hb_ntos(s[1]), iif(hb_isarray(s[2]), valtype(s[2]), valtype(s[2])))
?? iif(hb_isnumeric(s[2]), hb_ntos(s[2]), iif(hb_isarray(s[2]), valtype(s[2]), valtype(s[2])))
return

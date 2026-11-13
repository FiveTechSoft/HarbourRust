// ains 1b step (c): independent fixture, not Harbour source
local a := {{1}}
show(a)
return
procedure show(s)
?? iif(hb_isnumeric(s[1]), hb_ntos(s[1]), s[1])
return

// ains 1b step (c): independent fixture, not Harbour source
local a := {1,"x",NIL,.T.}
show(a)
return
procedure show(s)
local n
for n := 1 to len(s)
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), valtype(s[n]))
?? ","
next
return

// ains 1b step (c)-next: independent fixture, not Harbour source
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"x",NIL,.T.,22,"yy"}
local i
for i := 1 to 1000
show(a)
next
return 0
procedure show(s)
local n
for n := 1 to len(s)
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), s[n])
?? ","
next
return

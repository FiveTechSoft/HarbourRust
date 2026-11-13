// ains 1b step (c)-next: independent fixture, not Harbour source
// iif raw Dyn cell arm in immediate output: all measured cell tags.
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"x",NIL,.T.,.F.,22}
show(a)
return 0
procedure show(s)
local n
for n := 1 to len(s)
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), s[n])
?? "|"
next
return

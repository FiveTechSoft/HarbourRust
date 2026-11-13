// ains 1b step (c)-next: independent fixture, not Harbour source
// aDump-shaped recursion: nested arrays through the raw-cell iif
// (nested literal cells are int/NIL scalars in this increment).
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {{1,2},{3,NIL}}
adump2(a)
return 0
procedure adump2(s)
local n
for n := 1 to len(s)
if hb_isarray(s[n])
?? "["
adump2(s[n])
?? "]"
else
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), s[n])
endif
?? ","
next
return

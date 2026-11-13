// ains 1b step (c): independent fixture, not Harbour source
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {{1,2},{3,4}}
dump(a)
return 0
procedure dump(s)
local n
for n := 1 to len(s)
if hb_isarray(s[n])
dump(s[n])
else
?? iif(hb_isnumeric(s[n]), hb_ntos(s[n]), valtype(s[n]))
?? ","
endif
next
return

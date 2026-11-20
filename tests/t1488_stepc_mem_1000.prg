// ains 1b step (c): independent fixture, not Harbour source
procedure main()
? wrap()
? hb_memcheck()
return
function wrap()
local a := {1,"x",22,"yy",333,NIL,.T.,"zzz"}
local i
for i := 1 to 1000
show(a)
next
return 0
procedure show(s)
local n
for n := 1 to len(s)
if hb_isnumeric(s[n])
OutStd(hb_ntos(s[n]))
else
OutStd(valtype(s[n]))
endif
next
return

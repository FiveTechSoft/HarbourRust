// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := array(1,1,1,2)
walk(a)
? len(a)
return
procedure walk(s)
local n
for n := 1 to len(s)
?? valtype(s[n])
if hb_isarray(s[n])
walk(s[n])
endif
next
return

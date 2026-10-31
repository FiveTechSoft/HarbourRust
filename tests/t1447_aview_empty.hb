// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := {}
show(a)
? len(a)
return
procedure show(s)
local n
for n := 1 to len(s)
?? valtype(s[n])
next
? len(s)
return

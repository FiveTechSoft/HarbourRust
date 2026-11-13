// ains 1b step (b): independent fixture, not Harbour source
procedure main()
run()
? hb_memcheck()
return
procedure run()
local a := {1,"x",NIL,.T.}
local i
for i := 1 to 5
show(a)
next
return
procedure show(s)
local n
for n := 1 to len(s)
?? valtype(s[n])
next
return

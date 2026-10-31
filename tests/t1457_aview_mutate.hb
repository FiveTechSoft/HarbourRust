// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := { 1, 2 }
outer(a)
return
procedure outer(s)
? valtype(s[1])
sink(s)
return
procedure sink(t)
t[1] := 5
return

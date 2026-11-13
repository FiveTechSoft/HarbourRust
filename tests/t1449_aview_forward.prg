// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := { 1, 2 }
outer(a)
? a[1]
return
procedure outer(s)
inner(s)
return
procedure inner(t)
? len(t)
? valtype(t[1])
return

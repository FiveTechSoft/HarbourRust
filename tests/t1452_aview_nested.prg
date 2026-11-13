// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := {1,2}
local b := {3,4}
local c := {5,6}
show(a, check(b), c)
? a[1]
? b[1]
? c[1]
return
function check(s)
?? valtype(s[1])
return len(s)
procedure show(s,n,t)
?? valtype(s[n])
?? valtype(t[n])
return

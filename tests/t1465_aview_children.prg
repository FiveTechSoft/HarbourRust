// ains 1b step (b): independent fixture, not Harbour source
procedure main()
local a := {{1,2},{3,4}}
local b := {{5,6}}
outer(a,b)
return
procedure outer(s,t)
?? valtype(s[1])
?? valtype(t[1])
inner(s[1], check(t[1]), s[2])
return
function check(u)
?? valtype(u[1])
return len(u)
procedure inner(x,n,y)
?? valtype(x[n])
?? valtype(y[n])
return

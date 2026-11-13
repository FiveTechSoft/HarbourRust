// direct output expression must not free a borrowed array-view cell
procedure main()
local a := {1,"x",NIL}
show(a)
return
procedure show(s)
?? valtype(s[1])
outerr(s[2])
return

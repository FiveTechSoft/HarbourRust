procedure main()
 f(7,8,9)
 return
function f(a,...)
 local x:=hb_AParams()
 a:=11
 x[2]:=22
 ? a,hb_PValue(2),x[1],x[2]

 return NIL

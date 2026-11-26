procedure main()
 f(3,"hello")
 return
function f(a,...)
 local x:=hb_AParams()
 if a>0
 f(a-1,"inner")
 endif
 ? x[1],x[2]
 return NIL

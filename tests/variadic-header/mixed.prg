procedure main()
 f(1,"hello",.T.,2.50,NIL)
 f(2,"world",.F.,7.25)
 return
function f(a,...)
 local i, x
 ? a,PCount()
 for i:=1 to 7
 x:=hb_PValue(i)
 ? ValType(x),x
 next
 return NIL

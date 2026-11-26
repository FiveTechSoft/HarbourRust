procedure main()
 f(1,"hello",.T.,2.50,NIL)
 f(2)
 return
function f(a,...)
 local x:=hb_AParams(),i
 ? Len(x)
 for i:=1 to Len(x)
 ? x[i]
 next
 return NIL

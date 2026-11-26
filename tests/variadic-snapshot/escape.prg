procedure main()
 local x:=f(1,"hello",.T.,2.50),i
 for i:=1 to Len(x)
 ? x[i]
 next
 return
function f(...)
 local x:=hb_AParams()
 return x

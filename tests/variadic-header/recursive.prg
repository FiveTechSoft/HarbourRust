procedure main()
 ? f(3),f(3,7)
 return
function f(n,...)
 local before:=PCount(), x:=0
 if n>0
 x:=f(n-1)
 endif
 return before*100+PCount()+x

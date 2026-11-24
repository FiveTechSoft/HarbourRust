FUNCTION Main()
 LOCAL a:={{1,"a"},{2,"b"}},n:=1
 ASort(a,NIL,NIL,{|x,y|x[n]<y[1]})
RETURN NIL

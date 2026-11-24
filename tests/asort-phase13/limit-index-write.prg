FUNCTION Main()
 LOCAL a:={{1},{2}},n:=1
 ASort(a,NIL,NIL,{|x,y|x[n++]<y[1]})
RETURN NIL

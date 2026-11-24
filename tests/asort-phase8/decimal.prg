FUNCTION Main()
 LOCAL a:={{1.5,"a"},{-2,"b"},{1.5,"c"},{0.25,"d"},{2,"e"},{-2.0,"f"}},i
 FOR i:=1 TO 97
  ASort(a,NIL,NIL,{|x,y|x[1]>y[1]})
  ASort(a,NIL,NIL,{|x,y|x[1]<y[1]})
 NEXT
 FOR i:=1 TO Len(a)
  ? a[i][1],a[i][2]
 NEXT
RETURN NIL

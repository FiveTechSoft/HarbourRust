FUNCTION Main()
 LOCAL a:={{9,"a"},{3,"b"},{1,"c"},{3,"d"},{2,"e"},{8,"f"}},i
 ASort(a,2,4,{|x,y|x[1]<y[1]})
 FOR i:=1 TO Len(a)
  ? a[i][1],a[i][2]
 NEXT
RETURN NIL

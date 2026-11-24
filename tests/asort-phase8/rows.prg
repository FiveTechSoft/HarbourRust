FUNCTION Main()
 LOCAL a,n,b
 a:={{2,"a"},{1,"b"},{2,"c"},{1,"d"},{2,"e"},{1,"f"},{0,"g"}}
 b:=a
 ASort(a,NIL,NIL,{|x,y|x[1]<y[1]})
 FOR n:=1 TO Len(a)
  ?? a[n][2]
 NEXT
 ? b[1][2],b[7][2]
 a:={{2,"a"},{1,"b"},{2,"c"},{1,"d"},{2,"e"},{1,"f"},{0,"g"}}
 ASort(a,NIL,NIL,{|x,y|x[1]<=y[1]})
 FOR n:=1 TO Len(a)
  ?? a[n][2]
 NEXT
 ? b[1][2],b[7][2]
RETURN NIL

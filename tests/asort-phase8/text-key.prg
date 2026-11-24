FUNCTION Main()
 LOCAL a:={{"zz",1},{"a",2},{"",3},{"aa",4},{"a",5}},i
 ASort(a,NIL,NIL,{|x,y|x[1]<y[1]})
 FOR i:=1 TO Len(a)
  ? a[i][1],a[i][2]
 NEXT
RETURN NIL

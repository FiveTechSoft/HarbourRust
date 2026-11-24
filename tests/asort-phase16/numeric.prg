FUNCTION Main()
 LOCAL a:={3,1,2,5,4},i:=0
 FOR i:=1 TO 101
  ASort(a,NIL,NIL,{|x,y|x+1<y})
 NEXT
 ? a[1],a[2],a[3],a[4],a[5]
RETURN NIL

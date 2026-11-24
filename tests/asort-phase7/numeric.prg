FUNCTION Main()
 LOCAL a:={1.5,-3,7,1.5,0,9.25,2},b:=a,i
 FOR i:=1 TO 101
  ASort(a,NIL,NIL,{|x,y|x>y})
  ASort(a,NIL,NIL,{|x,y|x<y})
 NEXT
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7]
 ? b[1],b[7],Len(ASort(a,NIL,NIL,{|x,y|x>y}))
RETURN NIL

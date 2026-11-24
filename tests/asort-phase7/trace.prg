FUNCTION Main()
 LOCAL a:={6,2,8,2,9,1,6,4,7},n
 FOR n:=2 TO 9
  a:={6,2,8,2,9,1,6,4,7}
  ASize(a,n)
  ? "N",n
  ASort(a,NIL,NIL,{|x,y|QOut(x,y),x<y})
  ? a[1],a[n]
 NEXT
RETURN NIL

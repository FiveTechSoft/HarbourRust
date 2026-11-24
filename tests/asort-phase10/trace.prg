STATIC s:=""
FUNCTION Record(a,b)
 s += "("+hb_ntos(a)+","+hb_ntos(b)+")"
RETURN a<b
FUNCTION Main()
 LOCAL a:={6,2,8,2,9,1,6,4,7},n
 FOR n:=2 TO 9
  a:={6,2,8,2,9,1,6,4,7}
  ASize(a,n)
  s:=""
  ASort(a,NIL,NIL,{|x,y|Record(x,y)})
  ? n,s
 NEXT
RETURN NIL

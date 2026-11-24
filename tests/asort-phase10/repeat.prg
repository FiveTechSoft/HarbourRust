STATIC s:=""
FUNCTION Record(a,b)
 s += "("+hb_ntos(a)+","+hb_ntos(b)+")"
RETURN a>b
FUNCTION Main()
 LOCAL a:={6,2,8,2,9,1,6},i
 FOR i:=1 TO 151
  s:=""
  ASort(a,2,5,{|x,y|Record(x,y)})
 NEXT
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7]
 ? s
RETURN NIL

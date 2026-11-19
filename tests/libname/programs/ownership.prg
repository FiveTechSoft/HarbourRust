FUNCTION Work()
 LOCAL s:="", d:="", i,n:=0
 FOR i:=1 TO 1000
  s:=hb_libName(Upper("name.ext"),Lower("DIR"))
  d:=hb_libName(NIL,Space(5))
  n:=n+Len(s)+Len(d)
 NEXT
 ? n,s, ">"+d+"<"
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

FUNCTION Take(s)
 LOCAL t:=Upper(s)
 s:=Upper("replacement!")
 t:=Upper("poisonedxxxx")
RETURN Lower(t)
FUNCTION Work()
 LOCAL s:="",d:="",i
 FOR i:=1 TO 1000
  s:=Upper("original.ext")
  d:=hb_libName(s,Take(s))
  s:=""
 NEXT
 ? d
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

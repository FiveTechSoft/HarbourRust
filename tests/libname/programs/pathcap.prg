FUNCTION Main()
 LOCAL n,s:=""
 FOR n:=258 TO 266
  s:=hb_libName(Replicate("d",n)+"/x.ext")
  ? n,Len(s),Left(s,5),Right(s,5)
 NEXT
RETURN NIL

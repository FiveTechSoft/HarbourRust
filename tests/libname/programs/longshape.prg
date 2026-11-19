FUNCTION Main()
 LOCAL n,s:=""
 FOR n:=252 TO 268
  s:=hb_libName(Replicate("a",n))
  ? n,Len(s),Right(s,10)
 NEXT
 s:=hb_libName(Replicate("d",300)+"/x.ext")
 ? Len(s),Left(s,10),Right(s,10)
 s:=hb_libName("x.ext",Replicate("d",300))
 ? Len(s),Left(s,10),Right(s,10)
 s:=hb_libName(Replicate("a",300)+".x")
 ? Len(s),Left(s,10),Right(s,10)
RETURN NIL

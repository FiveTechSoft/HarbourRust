FUNCTION Work()
 LOCAL h:=0,s:="seed",i,n:=0
 FOR i:=1 TO 1000
  h:=FCreate(Lower("OWN.DAT"))
  n:=n+FWrite(h,Upper("abc"))
  FClose(h)
  h:=FOpen(Lower("OWN.DAT"))
  s:=FReadStr(h,7)
  n:=n+Len(s)+Len(FReadStr(h,3))
  FClose(h)
 NEXT
 ? n,s
RETURN NIL
FUNCTION Main()
 Work()
RETURN NIL

FUNCTION Main()
 LOCAL n,c:="",s:="",p:=""
 FOR n:=250 TO 270
  c:=Replicate("x",n)
  p:="l"+hb_ntos(n)
  hb_FLinkSym(c,p)
  s:=hb_FLinkRead(p)
  ? n,Len(s),FError(),s==c
 NEXT
RETURN NIL

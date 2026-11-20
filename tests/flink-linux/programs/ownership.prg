FUNCTION Work()
 LOCAL i,s:="",r:=0
 FOR i:=1 TO 1000
  r:=r+hb_FLink("origin","ownership")
  s:=hb_FLinkRead("symbolic")
 NEXT
 ? r,s,FError()
RETURN NIL
FUNCTION Main()
 hb_FLink("origin","ownership")
 hb_FLinkSym("origin","symbolic")
 Work()
RETURN NIL

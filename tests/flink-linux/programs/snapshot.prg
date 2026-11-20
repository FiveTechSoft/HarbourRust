FUNCTION Consume(s)
 ? Upper(s)
RETURN "snapshot-link"
FUNCTION Main()
 LOCAL a:=Upper("origin")
 ? hb_FLink(a,Consume(a)),FError()
RETURN NIL

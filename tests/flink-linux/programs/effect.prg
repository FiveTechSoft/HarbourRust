FUNCTION Consume(p)
 p["effect"]:=1
 ? "effect"
RETURN "destination"
FUNCTION Main()
 LOCAL p:={"one"=>1},s:="origin"
 ? hb_FLink(s,Consume(p)),FError(),s
 ? hb_MemoWrit("binary","A"+Chr(0)+"B"),FError()
 ? hb_FLinkSym("origin","sym"),FError()
 ? hb_FLinkRead("sym"),FError()
RETURN NIL

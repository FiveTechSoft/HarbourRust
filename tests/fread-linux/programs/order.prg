FUNCTION Handle(p)
 p["visited"]:=1
 ? "handle"
RETURN -1
FUNCTION Main()
 LOCAL p:={"one"=>1},s:="keep"
 ? FRead(Handle(p),@s,2),s
RETURN NIL

FUNCTION Handle(p)
 p["visited"]:=1
RETURN -1
FUNCTION Main()
 LOCAL p:={"one"=>1},s:="keep"
 ? FRead(Handle(p),@s,2)
 ? Len(p)
RETURN NIL

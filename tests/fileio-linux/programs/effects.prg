FUNCTION Handle(p)
 p["visited"]:=1
 ? "handle"
RETURN -1
FUNCTION Text(p)
 p["visited"]:=1
 ? "text"
RETURN "payload"
FUNCTION PathName(p)
 p["visited"]:=1
 ? "path"
RETURN "effects.dat"
FUNCTION Main()
 LOCAL a:={"one"=>1},b:={"one"=>1},c:={"one"=>1}
 ? FWrite(Handle(a),Text(b))
 ? FClose(FCreate(PathName(c)))
RETURN NIL

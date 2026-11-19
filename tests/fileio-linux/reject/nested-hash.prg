FUNCTION Take(p)
 p["two"]:=2
RETURN "x"
FUNCTION Main()
 LOCAL h:={"one"=>1}
 ? FClose(FCreate(Take(h)))
 ? Len(h)
RETURN NIL

FUNCTION Mode(p)
 p["mode"]:=1
 ? "mode"
RETURN 3
FUNCTION Main()
 LOCAL p:={"one"=>1}
 ? SetCursor(),SetCursor(Mode(p)),SetCursor()
RETURN NIL

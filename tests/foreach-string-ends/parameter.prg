PROCEDURE Main()
 LOCAL s:="a"+Chr(0)+"é"
 Observe(s)
 ? s
RETURN
FUNCTION Observe(s)
 LOCAL v
 FOR EACH v IN s
 ? Asc(v),v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN NIL

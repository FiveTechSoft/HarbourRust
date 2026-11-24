PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(2)
 FOR EACH x IN a
  ? x:__enumIndex()
 NEXT
 ? x:__enumIndex()
RETURN

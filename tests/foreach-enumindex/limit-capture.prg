PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(2),b:={|| 0}
 FOR EACH x IN a
  b:={|| x:__enumIndex()}
 NEXT
RETURN

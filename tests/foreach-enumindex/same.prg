PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(3),b:=Array(2)
 FOR EACH x IN a
  ? x:__enumIndex()
  FOR EACH x IN b
   ? x:__enumIndex()
  NEXT
  ? x:__enumIndex()
 NEXT
RETURN

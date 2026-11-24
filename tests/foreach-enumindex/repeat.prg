PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(3),i:=0,n:=0
 FOR i:=1 TO 513
  FOR EACH x IN a
   n+=x:__enumIndex()
  NEXT
 NEXT
 ? n,ValType(x)
RETURN

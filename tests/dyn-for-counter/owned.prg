PROCEDURE Main()
 LOCAL n:=NIL,i:=0
 ? ValType(n)
 FOR i:=1 TO 17
  n:=1.25
  FOR n:=3 TO 1 STEP -1
   ? n
  NEXT
  ? n
 NEXT
RETURN

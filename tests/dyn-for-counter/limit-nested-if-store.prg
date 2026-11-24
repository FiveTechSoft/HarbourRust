PROCEDURE Main()
 LOCAL n:=NIL,j:=0
 ? ValType(n)
 FOR n:=1 TO 7
  FOR j:=1 TO 3
   IF j==2
    n:=3
   ENDIF
  NEXT
 NEXT
RETURN

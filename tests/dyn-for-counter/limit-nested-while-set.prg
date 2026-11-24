PROCEDURE Main()
 LOCAL n:=NIL,j:=0
 ? ValType(n)
 FOR n:=1 TO 7
  DO WHILE j<3
   ? (n:=2)
   j++
  ENDDO
 NEXT
RETURN

PROCEDURE Main()
 LOCAL n:=NIL,j:=NIL
 ? ValType(n),ValType(j)
 FOR n:=1 TO 3
  FOR j:=2 TO 4 STEP 2
   ? n,j
  NEXT
  ? j
 NEXT
 ? n,j
RETURN

// Own MIT. Folded integer step, unchanged counting semantics.
PROCEDURE Main()
 LOCAL i:=0,j:=0,n:=0
 FOR i:=1 TO 9 STEP (1+2)
  ? i
 NEXT
 ? i
 FOR i:=9 TO 1 STEP -(1+2)
  ? i
 NEXT
 ? i
 FOR i:=1 TO 9 STEP +((12/3)-2)
  FOR j:=4 TO 1 STEP (0-1)
   IF j==3
    LOOP
   ENDIF
   n+=i+j
   IF j==2
    EXIT
   ENDIF
  NEXT
 NEXT
 ? i,j,n
 FOR i:=1 TO 7 STEP (11%4)
  ? i
 NEXT
 ? i
RETURN

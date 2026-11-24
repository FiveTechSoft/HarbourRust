PROCEDURE Main()
 LOCAL n:=NIL,j:=0,total:=0
 ? ValType(n)
 FOR j:=1 TO 21
  n:=Replicate("owned",71)
  FOR n:=9 TO -3 STEP -2
   total+=n
   IF n==7
    LOOP
   ENDIF
   IF n==1
    EXIT
   ENDIF
  NEXT
 NEXT
 ? total,n,ValType(n)
 FOR n:=11 TO 3
  ? "unreachable"
 NEXT
 ? n,ValType(n)
 n:=NIL
 ? n,ValType(n)
RETURN

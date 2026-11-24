FUNCTION Main()
 LOCAL a:={1,"text"},i
 FOR i:=1 TO 17
  IF i%2==1
   a[1]:=a
  ELSE
   a[1]:=NIL
  ENDIF
 NEXT
 ? ValType(a[1]),a[2]
RETURN NIL

PROCEDURE Main()
 LOCAL s:=NIL,i:=0,n:=0
 FOR i:=1 TO 139
  FOR EACH s IN hb_ATokens("Lu;Ll;;xLu", ";")
   IF "Lu" $ s
    n++
   ENDIF
   ? "x" $ s,"" $ s
  NEXT
 NEXT
 ? n,ValType(s)
RETURN

FUNCTION alltrim(x)
 ? "MUST-NOT-RUN"
RETURN 17
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? alltrim(v)
 NEXT
RETURN

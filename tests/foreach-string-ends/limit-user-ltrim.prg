FUNCTION ltrim(x)
 ? "MUST-NOT-RUN"
RETURN 17
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? ltrim(v)
 NEXT
RETURN

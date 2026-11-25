FUNCTION rtrim(x)
 ? "MUST-NOT-RUN"
RETURN 17
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? rtrim(v)
 NEXT
RETURN

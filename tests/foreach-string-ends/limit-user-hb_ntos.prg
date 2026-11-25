FUNCTION hb_ntos(x)
 ? "MUST-NOT-RUN"
RETURN 17
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? hb_ntos(v)
 NEXT
RETURN

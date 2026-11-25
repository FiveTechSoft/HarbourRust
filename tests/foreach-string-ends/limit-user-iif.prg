FUNCTION IIf(cond,a,b)
 ? "MUST-NOT-RUN"
RETURN a
PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? IIf(v:__enumIsFirst,"first","other")
 NEXT
RETURN

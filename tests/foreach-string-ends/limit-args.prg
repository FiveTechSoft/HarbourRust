PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? v:__enumIndex(2)
 NEXT
RETURN

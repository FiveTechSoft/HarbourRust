PROCEDURE Main()
 LOCAL s:="abc",v:=NIL
 FOR EACH v IN s
 ? v:__enumIndex
 NEXT
 ? v:__enumIsLast
RETURN

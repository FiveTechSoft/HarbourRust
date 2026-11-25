PROCEDURE Main()
 LOCAL s:="abc",v:=NIL,w:=NIL
 FOR EACH v IN s
 FOR EACH w IN s
 ? w:__enumIndex
 NEXT
 NEXT
RETURN

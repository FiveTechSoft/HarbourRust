PROCEDURE Main()
 LOCAL h:={"x"=>1},s:="abc",v:=NIL
 FOR EACH v IN h
 FOR EACH v IN s
 ? v:__enumKey
 NEXT
 NEXT
RETURN

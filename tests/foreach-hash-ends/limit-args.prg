PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL
 FOR EACH v IN h
 ? v:__enumIsFirst(1)
 NEXT
RETURN

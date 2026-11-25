PROCEDURE Main()
 LOCAL h:={"a"=>1},a:={1,2},v:=NIL
 FOR EACH v IN h
 FOR EACH v IN a
 ? v:__enumIsLast()
 NEXT
 NEXT
RETURN

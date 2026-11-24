PROCEDURE Main()
 LOCAL h:={"a"=>1},a:=Array(2),v:=NIL
 FOR EACH v IN h
  FOR EACH v IN a
   ? v:__enumKey()
  NEXT
 NEXT
RETURN

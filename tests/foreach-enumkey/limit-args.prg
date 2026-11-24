PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL,a:=Array(2)
FOR EACH v IN h
 ? v:__enumKey(1)
NEXT
RETURN

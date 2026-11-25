PROCEDURE Main()
 LOCAL h:={"a"=>1},v:=NIL,b:=NIL
 FOR EACH v IN h
  b:={|| v:__enumIsFirst()}
 NEXT
RETURN

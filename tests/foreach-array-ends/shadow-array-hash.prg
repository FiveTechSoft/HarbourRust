PROCEDURE Main()
 LOCAL a:=Array(3),h:={"x"=>1,"y"=>2},v:=NIL
 FOR EACH v IN a
 ? "before",v:__enumIsFirst,v:__enumIsLast
 FOR EACH v IN h
 ? v:__enumKey,v:__enumIsFirst,v:__enumIsLast
 NEXT
 ? "after",v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN

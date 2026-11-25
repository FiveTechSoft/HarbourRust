PROCEDURE Main()
 LOCAL a:={"x"=>1,"y"=>2},s:="xyz",v:=NIL
 FOR EACH v IN a
 ? "before",v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 FOR EACH v IN s
 ? "inner",v,v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
 ? "after",v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN

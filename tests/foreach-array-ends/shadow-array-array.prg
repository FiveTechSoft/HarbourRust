PROCEDURE Main()
 LOCAL a:=Array(3),b:=Array(2),v:=NIL
 FOR EACH v IN a
 ? "before",v:__enumIsFirst,v:__enumIsLast
 FOR EACH v IN b
 ? "inner",v:__enumIsFirst,v:__enumIsLast
 NEXT
 ? "after",v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN

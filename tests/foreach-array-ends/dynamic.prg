PROCEDURE Main()
 LOCAL a:=Array(0),b:=Array(1),c:=Array(3),s:={"x","y"},t:={.T.,.F.},v:=NIL,i:=0
 FOR EACH v IN a
 ? "bad",v:__enumIsFirst,v:__enumIsLast
 NEXT
 FOR EACH v IN b
 ? "one",v:__enumIsFirst,v:__enumIsLast
 NEXT
 FOR i:=1 TO 73
 FOR EACH v IN c
 ? v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
 NEXT
 FOR EACH v IN s
 ? v,v:__enumIsFirst,v:__enumIsLast
 NEXT
 FOR EACH v IN t
 ? v,v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN

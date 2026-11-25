PROCEDURE Main()
 LOCAL a:=Array(3),s:="xy",v:=NIL,w:=NIL
 FOR EACH v IN a
 FOR EACH w IN s
 ? v:__enumIndex,w:__enumIndex,v:__enumIsFirst,w:__enumIsFirst,v:__enumIsLast,w:__enumIsLast
 IF w:__enumIsFirst .AND. v:__enumIsFirst
 LOOP
 ENDIF
 NEXT
 NEXT
RETURN

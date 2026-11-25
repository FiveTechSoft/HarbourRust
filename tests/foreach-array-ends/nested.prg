PROCEDURE Main()
 LOCAL a:=Array(3),b:=Array(2),v:=NIL,w:=NIL,f:=.F.,l:=.F.
 FOR EACH v IN a
 f:=v:__enumIsFirst
 l:=v:__enumIsLast
 FOR EACH w IN b
 ? v:__enumIndex,w:__enumIndex,f,l,w:__enumIsFirst,w:__enumIsLast
 IF w:__enumIsFirst
 LOOP
 ENDIF
 EXIT
 NEXT
 NEXT
RETURN

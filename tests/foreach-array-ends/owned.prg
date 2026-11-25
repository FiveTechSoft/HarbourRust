FUNCTION Early()
 LOCAL v:=NIL
 FOR EACH v IN Array(3)
 ? v:__enumIsFirst,v:__enumIsLast
 RETURN 7
 NEXT
RETURN 9
PROCEDURE Main()
 LOCAL v:=NIL,i:=0
 FOR i:=1 TO 31
 FOR EACH v IN Array(4)
 ? v:__enumIsFirst,v:__enumIsLast
 IF v:__enumIsFirst
 LOOP
 ENDIF
 IF v:__enumIsLast
 EXIT
 ENDIF
 NEXT
 NEXT
 ? Early()
RETURN

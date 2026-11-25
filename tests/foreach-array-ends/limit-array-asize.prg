PROCEDURE Main()
 LOCAL a:=Array(3),v:=NIL
 FOR EACH v IN a
 ASize(a,1)
 ? v:__enumIsLast
 NEXT
RETURN

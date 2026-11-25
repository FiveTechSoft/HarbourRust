PROCEDURE Main()
 LOCAL a:=Array(3),v:=NIL
 FOR EACH v IN a
 AAdd(a,4)
 ? v:__enumIsLast
 NEXT
RETURN

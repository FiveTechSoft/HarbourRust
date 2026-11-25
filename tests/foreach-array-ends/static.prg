PROCEDURE Main()
 LOCAL a[3],v:=NIL
 a[1]:=10
 a[2]:=20
 a[3]:=30
 FOR EACH v IN a
 ? v,v:__enumIndex,v:__enumIsFirst,v:__enumIsLast
 NEXT
RETURN

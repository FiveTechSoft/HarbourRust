PROCEDURE Main()
 LOCAL x:=NIL,a:=Array(3),n:=0,b:={0,0,0}
 FOR EACH x IN a
  n:=x:__enumIndex
  b[x:__enumIndex()]:=n
 NEXT
 ? n,b[1],b[2],b[3]
RETURN

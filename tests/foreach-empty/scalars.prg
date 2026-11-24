PROCEDURE Main()
 LOCAL a:=Array(6)
 LOCAL x:=NIL
 LOCAL i:=0
 a[2]:=0
 a[3]:=1
 a[4]:=-1
 a[5]:=.F.
 a[6]:=.T.
 FOR i:=1 TO 73
  FOR EACH x IN a
   ? x,Empty(x)
  NEXT
 NEXT
 ? ValType(x)
RETURN

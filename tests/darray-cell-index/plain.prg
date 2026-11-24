PROCEDURE Main()
 LOCAL a:=AFill(Array(7),0),b:=AFill(Array(7),0),i:=NIL,j:=0
 ? ValType(i)
 FOR j:=1 TO 91
  FOR i:=1 TO 7
   a[i]:=8-i
   b[a[i]]:=i
  NEXT
 NEXT
 ? b[1],b[7],i
RETURN

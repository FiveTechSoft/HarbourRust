PROCEDURE Main()
 LOCAL a[2,3,2],b[2,2,2,2],i:=0
 FOR i:=1 TO 71
  a[1,2,1]:=17
  b[2,1,2,1]:=23
  ? Len(a),Len(a[1]),Len(a[1,1]),a[1,2,1],b[2,1,2,1],ValType(b[1,1,1,1])
 NEXT
RETURN

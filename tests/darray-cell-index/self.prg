PROCEDURE Main()
 LOCAL a:=AFill(Array(3),1),j:=0
 FOR j:=1 TO 71
  a[1]:=2
  a[a[1]]:=3
  a[a[2]]:=1
 NEXT
 ? a[1],a[2],a[3]
RETURN

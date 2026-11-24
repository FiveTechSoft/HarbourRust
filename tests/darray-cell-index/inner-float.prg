PROCEDURE Main()
 LOCAL src:=AFill(Array(2),2),a:=Array(3),i:=NIL,j:=0
 FOR j:=1 TO 137
  i:=1.99
  a[src[i]]:=j
 NEXT
 ? a[1],a[2],a[3]
RETURN

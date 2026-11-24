PROCEDURE Main()
 LOCAL a:=AFill(Array(13),0),n:=NIL
 ? ValType(n)
 FOR n:=1 TO Len(a)
  a[n]:=n
 NEXT
 ? a[1],a[13],n
RETURN

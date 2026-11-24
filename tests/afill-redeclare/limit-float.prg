PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 19
  LOCAL a:=NIL
  a:=AFill(Array(13),0)
  a[1]:=1.25
  a[13]:=-2.75
  ? a[1],a[13]
 NEXT
RETURN

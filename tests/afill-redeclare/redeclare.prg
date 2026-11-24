PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 7
  LOCAL a:=NIL
  a:=AFill(Array(17),3)
  ? Len(a),a[17]
 NEXT
RETURN

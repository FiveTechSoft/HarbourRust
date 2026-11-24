PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 17
  LOCAL a:=NIL
  a:=AFill(Array(23),.T.)
  ? Len(a),a[23]
 NEXT
RETURN

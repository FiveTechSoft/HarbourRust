FUNCTION afdim()
 ? "dimension"
RETURN 3
PROCEDURE Main()
 LOCAL i:=0
 LOCAL a:=AFill(Array(afdim()),4)
 ? a[1],a[3]
 FOR i:=1 TO 257
  a:=AFill(Array(i),-5)
  ? Len(a)
 NEXT
RETURN

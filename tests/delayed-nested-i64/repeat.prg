PROCEDURE Main()
 LOCAL j:=0
 FOR j:=1 TO 101
 Probe()
 NEXT
RETURN
FUNCTION Probe()
 LOCAL a
 a:={{1,2},{3}}
 ? a[1][2],a[2][1]
RETURN NIL

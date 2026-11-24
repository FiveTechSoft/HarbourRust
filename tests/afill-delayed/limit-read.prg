FUNCTION ad_probe()
RETURN 1
PROCEDURE Main()
 LOCAL a,n:=2
 ? ValType(a)
 a:=AFill(Array(2),0)
 ? Len(a)
RETURN

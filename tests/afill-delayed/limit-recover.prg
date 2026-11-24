FUNCTION ad_probe()
RETURN 1
PROCEDURE Main()
 LOCAL a,n:=2
 BEGIN SEQUENCE
  a:=AFill(Array(2),0)
 RECOVER
  ? ValType(a)
 END SEQUENCE
 ? Len(a)
RETURN

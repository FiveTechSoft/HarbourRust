FUNCTION ad_probe()
RETURN 1
PROCEDURE Main()
 LOCAL a,n:=2
 IF .T.
  a:=AFill(Array(2),0)
 ENDIF
 ? Len(a)
RETURN

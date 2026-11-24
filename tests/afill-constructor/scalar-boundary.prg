PROCEDURE Main()
 LOCAL a:=AFill(Array(2),9223372036854775807)
 LOCAL b:=AFill(Array(2),-9223372036854775807)
 LOCAL c:=AFill(Array(3),1+2)
 ? a[1],a[2],b[1],b[2],c[1],c[3]
RETURN

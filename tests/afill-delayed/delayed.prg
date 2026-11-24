// Own MIT flat prefix, repeated function frames and full original size.
FUNCTION ad_make()
 LOCAL a,b,c,n
 a:=AFill(Array(65536),0)
 b:=AFill(Array(2),.T.)
 c:=AFill(Array(1),NIL)
 n:=Len(a)
 a[1]:=17
 ? n,a[1],a[65536],b[2],ValType(c[1])
RETURN 1
PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 31
  ? ad_make()
 NEXT
RETURN

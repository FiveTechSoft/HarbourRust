PROCEDURE Main()
 LOCAL n:=3,a[n],b[2,3],c[0],i:=0
 ? Len(a),ValType(a[1]),Len(b),Len(b[1]),Len(c)
 FOR i:=1 TO Len(a)
  a[i]:=i*2
 NEXT
 ? a[1],a[3]
RETURN

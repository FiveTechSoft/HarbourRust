// Own MIT fresh construction, sizes, scalar tags and independent buffers.
PROCEDURE Main()
 LOCAL a:=AFill(Array(65536),0)
 LOCAL b:=AFill(Array(3),-7)
 LOCAL c:=AFill(Array(2),.T.)
 LOCAL d:=AFill(Array(1),.F.)
 LOCAL e:=AFill(Array(2),NIL)
 LOCAL z:=AFill(Array(0),9)
 ? Len(a),a[1],a[65536]
 a[1]:=17
 ? a[1],a[2],a[65536]
 ? b[1],b[3],c[1],c[2],d[1],ValType(e[1]),ValType(e[2]),Len(z)
RETURN

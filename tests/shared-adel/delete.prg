FUNCTION Main()
 LOCAL a:=AClone({17,"word",19.25,{"child"}}),b:=a,c
 c:=a[4]
 ADel(a,2)
 ? Len(a),a[1],a[2],a[3,1],ValType(a[4]),b[2],c[1]
 ADel(a,0)
 ? b[1],a[2,1],ValType(a[3]),ValType(a[4])
 ADel(a,-1)
 ADel(a,99)
 ? Len(a),a[1],c[1]
 ADel(a,4)
 ? ValType(a[4])
 ADel(a,1)
 ? a[1,1],ValType(a[2])
 a:=AClone({})
 ADel(a,0)
 ? Len(a)
RETURN NIL

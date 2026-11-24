FUNCTION Main()
 LOCAL a:=AClone({17,"word",19.25,{"child"}}),b:=a,c
 c:=a[4]
 AIns(a,2)
 ? Len(a),a[1],ValType(a[2]),a[3],a[4],b[3],c[1]
 AIns(a,0)
 ? ValType(b[1]),a[2],ValType(a[3]),a[4]
 AIns(a,-1)
 AIns(a,99)
 ? Len(a),a[2],a[4]
 AIns(a,4)
 ? ValType(a[4])
 a:=AClone({})
 AIns(a,0)
 ? Len(a)
RETURN NIL

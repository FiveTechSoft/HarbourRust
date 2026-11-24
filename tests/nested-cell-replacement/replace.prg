FUNCTION Main()
 LOCAL a:={100,200,"Third"},b
 ? ValType({"A"}),ValType({}),ValType({1,2})
 a[3]:={"this",{"seems","to",{"work","so","well"}}}
 ? a[3][2][3][1]
 a[3,2][3,1]:="Harbour power!"
 b:=a
 ? b[3][2,3][1],Len(a),a[1],a[2]
RETURN NIL

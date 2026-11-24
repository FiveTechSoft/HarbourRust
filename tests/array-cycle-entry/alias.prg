FUNCTION Main()
 LOCAL a:={1},b
 a[1]:=a
 b:=a
 a:={9,8}
 ? Len(a),Len(b),ValType(b[1])
 b[1]:=NIL
 ? ValType(b[1])
RETURN NIL

FUNCTION Main()
 LOCAL a:={1,"owned",NIL}
 a[1]:=a
 a[2]:=Replicate("hello",23)
 ? ValType(a[1]),Len(a),Len(a[2])
RETURN NIL

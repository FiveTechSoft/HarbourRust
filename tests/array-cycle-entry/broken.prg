FUNCTION Main()
 LOCAL a:={1}
 a[1]:=a
 ? ValType(a[1]),Len(a[1])
 a[1]:=NIL
 ? ValType(a[1]),Len(a)
RETURN NIL

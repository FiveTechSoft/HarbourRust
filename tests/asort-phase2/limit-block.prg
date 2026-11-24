FUNCTION Put(a,x)
 a[1]:=x
RETURN NIL
FUNCTION Main()
 LOCAL a:={7,8}
 LOCAL b:={||1}
 Put(a,"text")
 ? Len(a)
RETURN NIL

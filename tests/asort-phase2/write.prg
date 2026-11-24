FUNCTION Put(a,x)
 a[1]:=x
RETURN NIL
FUNCTION Main()
 LOCAL a:={1,"old"}
 Put(a,"new")
 Put(a,23)
 ? a[1],a[2]
RETURN NIL

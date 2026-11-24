FUNCTION Main()
 LOCAL s:="abc",a
 a:=s
 F(@s)
 ? s
RETURN NIL
FUNCTION F(x)
 x:="z"
RETURN NIL

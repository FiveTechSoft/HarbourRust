FUNCTION G( s )
RETURN s + "!"
FUNCTION Main()
 LOCAL s := "a" + "b", r
 r := G(s)+"y" < "z"
 ? r
RETURN NIL

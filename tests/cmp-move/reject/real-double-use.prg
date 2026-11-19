FUNCTION G( s )
RETURN s + "!"
FUNCTION Main()
 LOCAL s := "a" + "b", r
 r := G(s) == G(s)
 ? r
RETURN NIL

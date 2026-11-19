FUNCTION G( s )
RETURN s + "!"
FUNCTION Main()
 LOCAL s := "a" + "b", r
 r := G(s)+"y" == NIL
 ? r
RETURN NIL

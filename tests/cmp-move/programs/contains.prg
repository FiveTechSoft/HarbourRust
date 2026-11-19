FUNCTION G( s )
RETURN s + "!"
FUNCTION Main()
 LOCAL s := "a" + "b", r
 r := G(s)+"y" $ "xab!yz"
 ? r
RETURN NIL

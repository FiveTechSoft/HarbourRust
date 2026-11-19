FUNCTION G( s )
RETURN s + "!"
FUNCTION Main()
 LOCAL s := "a" + "b", r
 r := G(s)+"y" = "ab!y"
 ? r
RETURN NIL

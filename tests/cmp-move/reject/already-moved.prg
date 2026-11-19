FUNCTION G(s)
RETURN s+"!"
FUNCTION Main()
 LOCAL s := "a"+"b", t := "c"+"d", r
 r := G(s)
 r := G(s) == "ab!"
 ? r
RETURN NIL

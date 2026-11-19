FUNCTION G(s)
RETURN s+"!"
FUNCTION Main()
 LOCAL s := "a"+"b", t := "c"+"d", r
 r := NIL == G(s)+"y"
 ? r
RETURN NIL

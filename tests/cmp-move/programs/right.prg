FUNCTION G(s)
RETURN s+"!"
FUNCTION Main()
 LOCAL s := "a"+"b", t := "c"+"d", r
 r := "ab!y" == G(s)+"y"
 ? r
RETURN NIL

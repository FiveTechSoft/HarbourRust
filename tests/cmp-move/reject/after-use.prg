FUNCTION G(s)
RETURN s+"!"
FUNCTION Main()
 LOCAL s := "a"+"b", t := "c"+"d", r
 r := G(s)+"y" == "ab!y"
 ? s
RETURN NIL

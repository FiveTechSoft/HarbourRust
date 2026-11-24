STATIC s:=""
FUNCTION Evil()
 s:="oops"
RETURN 7
FUNCTION Main()
 s += hb_ntos(Evil())
 ? s
RETURN NIL

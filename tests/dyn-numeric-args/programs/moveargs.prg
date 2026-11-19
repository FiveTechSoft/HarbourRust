FUNCTION G( s )
RETURN s + "!"
FUNCTION F( a, x )
 ? a, x
RETURN a
FUNCTION Main()
 LOCAL s := "a" + "b"
 F( G( s ) + "y", 1 )
 s := "a" + "b"
 F( ( G( s ) ) + "y", 2 )
RETURN NIL

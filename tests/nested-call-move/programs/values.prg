FUNCTION G( s )
RETURN s + "!"
FUNCTION F( a, x )
 ? a, x
RETURN a
FUNCTION Plus1( n )
RETURN n + 1
FUNCTION H( a )
 ? a
RETURN NIL
FUNCTION Main()
 LOCAL s := "a" + "b", d := 2, r
 F( G( s ), 1 )
 s := "c" + "d"
 F( G( s ), d )
 s := "e" + "f"
 F( 1, G( s ) )
 s := "g" + "h"
 F( G( G( s ) ), 1 )
 s := "i" + "j"
 H( G( s ) )
 s := "k" + "l"
 r := F( G( s ), 1 )
 ? r
 s := "m" + "n"
 F( G( s ) + "y", 1 )
 s := "o" + "p"
 F( Left( G( s ), 2 ), 1 )
 s := "q" + "r"
 F( s + "x", 1 )
 s := "u" + "v"
 ? Plus1( ( Asc( G( s ) ), 1 ) )
RETURN NIL

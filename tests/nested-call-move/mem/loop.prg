FUNCTION G( s )
RETURN s + "!"
FUNCTION F( a, x )
RETURN NIL
FUNCTION K( a, x )
RETURN NIL
FUNCTION Make( i )
RETURN "row" + Str( i, 3 )
FUNCTION Round1( nn )
 LOCAL i, s := Make( 0 ), d := 2
 FOR i := 1 TO nn
  F( G( s ), d )
  s := Make( i )
  F( G( G( s ) ), i )
  s := Make( i )
  K( i, G( s ) )
  s := Make( i )
  F( G( s ) + "y", 1 )
  s := Make( i )
 NEXT
RETURN NIL
FUNCTION Main()
 LOCAL baseline
 Round1( @N@ )
 baseline := hb_memcheck()
 Round1( @N@ )
 ? "pending", hb_memcheck() - baseline
RETURN NIL

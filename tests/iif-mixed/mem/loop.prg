FUNCTION Fails()
 Break( "expected" )
RETURN "never"
FUNCTION Text( i )
RETURN "row" + Str( i, 3 )
FUNCTION Take( v )
 RETURN NIL
FUNCTION Round1( nn )
 LOCAL i, x, c := "kept", own := Text( 0 ), hits := 0
 FOR i := 1 TO nn
  x := IIf( i % 2 == 0, Text( i ), i )
  x := IIf( i % 3 == 0, c, i * 2 )
  x := IIf( i % 5 == 0, 1.5, Text( i ) )
  x := IIf( i % 7 == 0, NIL, Text( i ) )
  x := IIf( i % 2 == 0, own, 7 )
  own := Text( i )
  x := IIf( i % 4 == 0, .T., c + "!" )
  TRYBLOCK
 NEXT
 ? "hits", hits
RETURN x
FUNCTION Main()
 LOCAL baseline, x
 x := Round1( @N@ )
 baseline := hb_memcheck()
 x := Round1( @N@ )
 ? "pending", hb_memcheck() - baseline
RETURN NIL

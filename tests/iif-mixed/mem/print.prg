FUNCTION Text( i )
RETURN "row" + Str( i, 3 )
FUNCTION Round1( nn )
 LOCAL i, c := "kept"
 FOR i := 1 TO nn
  ? IIf( i % 2 == 0, Text( i ), i )
  ? IIf( i % 3 == 0, c, i * 2 )
  ? IIf( i % 5 == 0, 1.5, Text( i ) )
  ? IIf( i % 7 == 0, NIL, Text( i ) )
 NEXT
RETURN NIL
FUNCTION Main()
 LOCAL baseline
 Round1( 20 )
 baseline := hb_memcheck()
 Round1( 20 )
 ? "pending", hb_memcheck() - baseline
RETURN NIL

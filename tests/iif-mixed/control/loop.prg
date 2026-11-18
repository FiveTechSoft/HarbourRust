FUNCTION NeedInt( x )
RETURN x + 1
FUNCTION Round1( nn )
 LOCAL i, hits := 0, a := { 1, 2, 3 }, r, k
 FOR i := 1 TO nn
  TRY
   r := hb_ntos( IIf( i % 2 == 0, 3, 1 ) )
   k := NeedInt( IIf( i % 2 == 0, 2, 1 ) )
   k := a[ IIf( i % 2 == 0, 1, 2 ) ]
   IF i % 2 == 0
    Break( "expected" )
   ENDIF
  CATCH
   hits++
  END
 NEXT
RETURN hits
FUNCTION Main()
 LOCAL baseline, h
 h := Round1( @N@ )
 baseline := hb_memcheck()
 h := Round1( @N@ )
 ? "hits", h
 ? "pending", hb_memcheck() - baseline
RETURN NIL

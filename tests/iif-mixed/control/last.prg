FUNCTION Text( i )
RETURN "row" + Str( i, 3 )
FUNCTION Round1( nn )
 LOCAL i, hits := 0
 FOR i := 1 TO nn
  TRY
   ? i, IIf( i % 2 == 0, Text( i ), i )
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

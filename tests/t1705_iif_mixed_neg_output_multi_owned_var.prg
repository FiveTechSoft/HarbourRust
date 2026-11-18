FUNCTION Fails()
 Break( "expected" )
RETURN "never"
FUNCTION Round1( nn )
 LOCAL i, hits := 0, s := "own" + "ed"
 FOR i := 1 TO nn
  TRY
   ? IIf(.T.,s,1), Fails()
  CATCH
   hits++
  END
 NEXT
RETURN hits
FUNCTION Main()
 LOCAL baseline, h
 h := Round1( 50 )
 baseline := hb_memcheck()
 h := Round1( 50 )
 ? "hits", h, "pending", hb_memcheck() - baseline
RETURN NIL

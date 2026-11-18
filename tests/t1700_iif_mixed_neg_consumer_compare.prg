
FUNCTION Round1( nn )
 LOCAL i, hits := 0, a := {1,2,3}, n := 0, r
 FOR i := 1 TO nn
  TRY
   IF IIf( .T., "x", 1 ) < 2 ; r := 1 ; ENDIF
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

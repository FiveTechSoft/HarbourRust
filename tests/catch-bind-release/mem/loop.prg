// catch-variable reuse in a loop; each kind of value Break() admits. Independent fixture.
function Own()
return "own" + "ed"
function Round1( nn )
 local i, e, hits := 0, a, b, d
 a := 1.5
 b := 2
 for i := 1 to nn
  KINDPRE
  TRY
   Break( KINDEXPR )
  CATCH e
   hits++
   KINDPOST
  END
 next
return hits
function Main()
 local baseline, h
 h := Round1( @N@ )
 baseline := hb_memcheck()
 h := Round1( @N@ )
 ? "hits", h
 ? "pending", hb_memcheck() - baseline
return nil

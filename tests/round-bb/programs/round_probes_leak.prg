// Owned-temporary leak regression (reviewer): the invalid-argument path
// must release every owned temporary it evaluates. Round(Id(0.1+0.2),
// "x") evaluates an owned heap-float Dyn and discards it before raising
// the argument error; Round(Id("abc"), "x") discards an owned string
// Dyn; Round({}, 0) / Round(1.23456, {}) discard the raw empty-array
// temporary (oracle shapes L_1052/L_1053/K_1039 - base d65a8392
// rejected these at compile time, so admitting them must not leak).
// hb_memcheck() pending must be 0 after the warm-up baseline.
function Id( v )
return v
function Leak1( nn )
   local i, r, hits
   hits := 0
   for i := 1 to nn
      TRY
         r := Round( Id( 0.1 + 0.2 ), "x" )
      CATCH
         hits++
      END
      TRY
         r := Round( Id( "abc" ), "x" )
      CATCH
         hits++
      END
      TRY
         r := Round( {}, 0 )
      CATCH
         hits++
      END
      TRY
         r := Round( 1.23456, {} )
      CATCH
         hits++
      END
   next
   ? "hits", hits
return 0
function Main()
   local baseline
   Leak1( 500 )
   baseline := hb_memcheck()
   Leak1( 500 )
   ? "pending", hb_memcheck() - baseline
return nil

// Leak probe: hb_ATokens results, separators and error paths must all
// be released. pending must be 0 after the warm-up baseline.
PROCEDURE Leak1( n )
   LOCAL i := 0
   LOCAL r := hb_ATokens("x")
   LOCAL s := ""
   LOCAL e
   FOR i := 1 TO n
      r := hb_ATokens("alpha,beta,,gamma delta", ",")
      s := r[ 1 ]
      r := hb_ATokens("say 'hi there' now", NIL, .T.)
      s := r[ 2 ]
      r := hb_ATokens("a b", .T.)
      s := r[ 1 ]
      BEGIN SEQUENCE WITH {| x | Break( x ) }
         r := hb_ATokens(44)
      RECOVER USING e
         s := hb_CStr( e )
      END SEQUENCE
   NEXT
   ? "last", s
   RETURN
PROCEDURE Main()
   LOCAL baseline
   Leak1( 500 )
   baseline := hb_memcheck()
   Leak1( 500 )
   ? "pending", hb_memcheck() - baseline
   RETURN

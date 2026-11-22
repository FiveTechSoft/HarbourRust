// Leak probe: Val() with owned-string arguments, extra arguments
// (evaluated for effects) and the argument-error path must release
// everything. pending must be 0 after the warm-up baseline.
PROCEDURE Leak1( n )
   LOCAL i := 0
   LOCAL r := Val("0")
   LOCAL k := 0
   LOCAL e
   FOR i := 1 TO n
      r := Val("12.5" + Chr(9))
      r := Val("1.5", "extra" + Chr(32), .T.)
      r := Val(Replicate("9", 50))
      BEGIN SEQUENCE WITH {| x | Break( x ) }
         r := Val(Date())
      RECOVER USING e
         k := Len( hb_CStr( e ) )
      END SEQUENCE
   NEXT
   ? "last", r, k
   RETURN
PROCEDURE Main()
   LOCAL baseline
   Leak1( 500 )
   baseline := hb_memcheck()
   Leak1( 500 )
   ? "pending", hb_memcheck() - baseline
   RETURN

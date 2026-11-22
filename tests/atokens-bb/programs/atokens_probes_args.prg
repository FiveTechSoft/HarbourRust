// Reviewer findings: argument evaluation hazards + result sizing in the
// hb_ATokens arm.
FUNCTION Consume( s )
   RETURN s + "!"
PROCEDURE Leak1( n )
   LOCAL i := 0
   LOCAL big := Replicate("xy ", 2000)
   LOCAL r := hb_ATokens("x")
   LOCAL s := ""
   FOR i := 1 TO n
      // 2000 tokens from a 6000-byte string: the result block must be
      // sized by its live count, not by the scan capacity.
      r := hb_ATokens(big, " ")
      s := r[ 1 ]
   NEXT
   ? "sized", Len(r), s
   RETURN
PROCEDURE Main()
   LOCAL e
   LOCAL k := 0
   LOCAL t := hb_ATokens("x")
   LOCAL baseline
   // nested aggregates: catchable Argument error, never a panic.
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      t := hb_ATokens({{1}})
      k := Len(t)
   RECOVER USING e
      k := Len( hb_CStr( e ) )
   END SEQUENCE
   ? "nested-arr", k
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      t := hb_ATokens({"k" => {1}})
      k := Len(t)
   RECOVER USING e
      k := Len( hb_CStr( e ) )
   END SEQUENCE
   ? "nested-hash", k
   Leak1( 200 )
   baseline := hb_memcheck()
   Leak1( 200 )
   ? "pending", hb_memcheck() - baseline
   RETURN

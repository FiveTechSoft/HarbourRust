// Reviewer findings: argument evaluation hazards in the Val arm.
FUNCTION Consume( s )
   RETURN s + "!"
PROCEDURE Main()
   // "4" + Chr(50): a heap-OWNED StrOwn variable - a literal would be
   // rodata-backed and could not reproduce the use-after-free.
   LOCAL s := "4" + Chr(50)
   LOCAL r := 0.0
   LOCAL e
   LOCAL k := 0
   // UAF: a later argument frees the borrowed first argument.
   r := Val(s, Consume(s))
   ? "alias", r                 // must be 42 (read before the free)
   // owned temporary + throwing later argument: caught, nothing leaks.
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val("1" + "2", Round())
   RECOVER USING e
      k := Len( hb_CStr( e ) )
   END SEQUENCE
   ? "throw", k                 // caught Argument error
   // nested aggregates: catchable Argument error, never a panic.
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val({{1}})
   RECOVER USING e
      k := Len( hb_CStr( e ) )
   END SEQUENCE
   ? "nested-arr", k
   BEGIN SEQUENCE WITH {| x | Break( x ) }
      r := Val({"k" => {1}})
   RECOVER USING e
      k := Len( hb_CStr( e ) )
   END SEQUENCE
   ? "nested-hash", k
   RETURN

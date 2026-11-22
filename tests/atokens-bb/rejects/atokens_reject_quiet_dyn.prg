// Reviewer probe: a Dyn operand of `+` can raise at coercion time;
// with an owned temporary in argument 1 this must be a NAMED rejection.
PROCEDURE Main()
   LOCAL d := NIL
   ? Len( hb_ATokens("a" + "b", "x" + d) )
   RETURN

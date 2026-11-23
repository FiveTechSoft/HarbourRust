// Regression (v4): the same coercion nested inside an aggregate
// discard. {"x" + NIL} evaluates the coercion when the aggregate
// argument is discarded, so it is not quiet either.
PROCEDURE Main()
   ? Len( hb_ATokens(Chr(65), {"x" + NIL}) )
   RETURN

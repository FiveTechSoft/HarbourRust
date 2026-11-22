// Regression (v4, reviewer close on v3): NIL is Dyn-typed, so "x" + NIL
// is a runtime coercion that can raise while the owned first temporary
// is live. Must be a NAMED rejection, never a silent admit.
PROCEDURE Main()
   ? Len( hb_ATokens(Chr(65), "x" + NIL) )
   RETURN

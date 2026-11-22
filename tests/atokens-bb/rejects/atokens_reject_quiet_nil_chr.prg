// Regression (v4): NIL + 1 is statically I64, but the NIL -> i64
// conversion raises before chr() runs. A concrete static result type
// does not make the operand coercion-safe.
PROCEDURE Main()
   ? Len( hb_ATokens(Chr(65), Chr(NIL + 1)) )
   RETURN

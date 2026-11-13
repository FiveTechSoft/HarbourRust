// Omitted arguments bind NIL in every position (multiarg contract A1).
// Source = oracle probe p3 of the args proposal, verbatim; expected =
// semantic extract of oracle run3 (|U|N| / |N|U| / |U|U|).
PROCEDURE Main()
   ? "|" + F( , 2 ) + "|"
   ? "|" + F( 1, ) + "|"
   ? "|" + F( , ) + "|"
RETURN
FUNCTION F( a, b )
RETURN ValType( a ) + "|" + ValType( b )

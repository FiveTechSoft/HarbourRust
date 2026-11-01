// An index target is NOT the inline-assign form in argument position
// (contract A2): a[i] := stays a named parse rejection there.
PROCEDURE Main()
   LOCAL a := {1,2}
   ? F( a[1] := 5, 2 )
RETURN
FUNCTION F( x, y )
RETURN x + y

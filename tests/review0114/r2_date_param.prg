// A parameter used as a date by the date builtins is a date parameter
// (report against 0.11.4: `cdow` expects a date).
PROCEDURE Main()
   DateName( SToD( "20261116" ) )
   ? Stamp( SToD( "20000229" ) )
RETURN
FUNCTION DateName( d )
   ? CDow( d ), CMonth( d )
RETURN NIL
FUNCTION Stamp( d )
RETURN DToS( d ) + "/" + DToC( d )

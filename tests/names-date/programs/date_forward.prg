PROCEDURE Main()
   LOCAL d := SToD( "20261116" )
   ? DToS( Relay( d ) )
RETURN
FUNCTION Relay( d )
RETURN Identity( d )
FUNCTION Identity( d )
RETURN d

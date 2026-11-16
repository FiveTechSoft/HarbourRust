PROCEDURE Main()
   Probe( SToD( "20261116" ) )
   Probe( SToD( "" ) )
RETURN
PROCEDURE Probe( d )
   ? "[" + CDow( d ) + "]", "[" + CMonth( d ) + "]", "[" + DToS( d ) + "]"
   ? Str( DoW( d ), 2 ), Str( Year( d ), 4 ), Str( Month( d ), 2 ), Str( Day( d ), 2 )
RETURN

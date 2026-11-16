PROCEDURE Main()
   ? Relay( SToD( "20261116" ), 3 )
RETURN
FUNCTION Relay( d, n )
   IF n == 0
      RETURN DToS( d )
   ENDIF
RETURN Relay( d, n - 1 )

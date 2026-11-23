FUNCTION Dame( x )
RETURN x
FUNCTION Main()
   LOCAL a := {}
   AAdd( a, Dame( SToD( "20261123" ) ) )
   ? ValType( a[ 1 ] ), a[ 1 ]
RETURN NIL

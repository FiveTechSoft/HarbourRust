FUNCTION Largo( c )
RETURN Len( c )
FUNCTION Total( aNombres )
   LOCAL i, n := 0
   FOR i := 1 TO Len( aNombres )
      n += Largo( aNombres[ i ] )
   NEXT
RETURN n
FUNCTION Main()
   LOCAL a := {}
   AAdd( a, "uno" )
   AAdd( a, "cuatro" )
   ? Total( a )
RETURN NIL

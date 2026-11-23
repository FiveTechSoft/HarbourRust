FUNCTION Copia( aDatos )
   LOCAL a := IIf( aDatos == NIL, {}, aDatos )
   AAdd( a, 9 )
RETURN Len( a )
FUNCTION Main()
   LOCAL a := {}
   AAdd( a, 1 )
   ? Copia(), Copia( a ), Len( a )
RETURN NIL

FUNCTION Copia( aDatos )
   LOCAL a := IIf( aDatos == NIL, {}, aDatos )
RETURN Len( a )
FUNCTION Main()
   LOCAL a := {}
   AAdd( a, 1 )
   ? Copia(), Copia( a )
RETURN NIL

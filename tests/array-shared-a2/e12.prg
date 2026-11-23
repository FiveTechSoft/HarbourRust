// Arreglo local que pasa a un parametro sin tipo fijo, y elemento de un
// arreglo recibido que pasa a otra funcion. El arreglo se comparte: lo que
// agrega quien lo recibe lo ve quien lo paso.
FUNCTION Copia( aDatos )
   LOCAL a := IIf( aDatos == NIL, {}, aDatos )
RETURN Len( a )

FUNCTION Largo( c )
RETURN Len( c )

FUNCTION Total( aNombres )
   LOCAL i, n := 0
   FOR i := 1 TO Len( aNombres )
      n += Largo( aNombres[ i ] )
   NEXT
RETURN n

FUNCTION Clase( x )
RETURN ValType( x )

FUNCTION Clases( aValores )
   LOCAL i, c := ""
   FOR i := 1 TO Len( aValores )
      c += Clase( aValores[ i ] )
   NEXT
RETURN c

FUNCTION Agrega( aDatos, xValor )
   AAdd( aDatos, xValor )
RETURN Len( aDatos )

FUNCTION Main()
   LOCAL a := {}, b := {}, c := { "x", "yz" }, m := {}
   AAdd( a, 1 )
   AAdd( a, 2 )
   AAdd( b, "uno" )
   AAdd( b, "cuatro" )
   ? Copia(), Copia( a ), Len( a )
   AAdd( a, 3 )
   ? Copia( a ), a[ 3 ]
   ? Total( b ), Total( c ), Len( b ), b[ 2 ]
   AAdd( m, 7 )
   AAdd( m, "texto" )
   AAdd( m, .T. )
   AAdd( m, 2.5 )
   AAdd( m, NIL )
   ? Clases( m ), Len( m )
   ? Agrega( a, 4 ), Len( a ), a[ 4 ]
   ? Agrega( b, "seis" ), Total( b )
RETURN NIL

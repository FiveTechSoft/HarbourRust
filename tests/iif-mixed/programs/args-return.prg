FUNCTION Show( x )
 ? ValType( x ), x
RETURN NIL
FUNCTION Pick( k )
RETURN IIf( k == 1, "txt", 42 )
FUNCTION Main()
 LOCAL l := .T., v
 v := IIf( l, "s", 5 )
 Show( v )
 v := IIf( ! l, "s", 5 )
 Show( v )
 Show( Pick( 1 ) )
 Show( Pick( 2 ) )
RETURN NIL

FUNCTION Main()
 LOCAL l := .T., n := 7, c := "cadena"
 ? IIf( l, "uno", 1 )
 ? IIf( ! l, "uno", 1 )
 ? IIf( l, n, c )
 ? IIf( ! l, n, c )
 ? IIf( l, .F., "no logico" )
 ? IIf( ! l, .F., "no logico" )
 ? IIf( l, 1.5, "decimal" )
 ? IIf( ! l, 1.5, "decimal" )
 ? IIf( l, c + "!", n * 2 )
 ? IIf( ! l, c + "!", n * 2 )
RETURN NIL

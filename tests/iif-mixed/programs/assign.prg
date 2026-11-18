FUNCTION Main()
 LOCAL l := .T., x
 x := IIf( l, "asignado", 99 )
 ? x, ValType( x )
 x := IIf( ! l, "asignado", 99 )
 ? x, ValType( x )
 x := IIf( l, 2.5, .F. )
 ? x, ValType( x )
 x := IIf( l, NIL, 7 )
 ? ValType( x )
RETURN NIL

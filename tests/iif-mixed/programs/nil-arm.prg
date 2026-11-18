FUNCTION Main()
 LOCAL l := .T., x
 ? IIf( l, "a", NIL )
 ? IIf( ! l, "a", NIL )
 ? IIf( l, 5, NIL )
 ? IIf( ! l, 5, NIL )
 ? IIf( l, NIL, 1.5 )
 ? IIf( l, .T., NIL )
RETURN NIL

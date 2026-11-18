FUNCTION Main()
 LOCAL l := .T., t := "abc"
 LOCAL s := t + "ed"
 ? IIf( l, s, 3 )
 ? IIf( ! l, t, 3 )
 ? t
RETURN NIL

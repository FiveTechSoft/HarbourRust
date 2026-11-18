FUNCTION Boom()
 ? "BOOM"
RETURN "boom"
FUNCTION Main()
 LOCAL l := .T.
 ? IIf( l, 1, Boom() )
 ? IIf( ! l, 1, Boom() )
RETURN NIL

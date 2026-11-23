FUNCTION Make()
   LOCAL a := {}, b := a
   AAdd( a, "one" )
   AAdd( b, a )
RETURN a
FUNCTION Change( p )
   AAdd( p, 3.25 )
RETURN p
FUNCTION Exercise()
   LOCAL a := Make(), b := Change( a ), c := b
   IF Len(a) != 3 .OR. Len(b) != 3 .OR. c[1] != "one"
      Break("alias")
   ENDIF
   a := NIL
   b := NIL
   IF Len(c) != 3 .OR. Len(c[2]) != 3
      Break("cycle")
   ENDIF
   c[3] := 4.5
   c[1] := "changed" + Str( Len(c), 2 )
   ASize(c, 2)
   IF ValType(c[2]) != "A" .OR. Len(c) != 2
      Break("resize")
   ENDIF
RETURN NIL
FUNCTION Main()
   LOCAL i, baseline
   Exercise()
   baseline := hb_memcheck()
   FOR i := 1 TO 100
      Exercise()
   NEXT
   ? "pending", hb_memcheck()-baseline
RETURN NIL

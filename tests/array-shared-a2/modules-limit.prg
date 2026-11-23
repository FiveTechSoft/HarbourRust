STATIC retained := {}
FUNCTION Save(p)
   retained := p
RETURN NIL
FUNCTION Exercise()
   LOCAL a := {}, b := a
   AAdd(a,"saved")
   AAdd(b,b)
   Save(a)
RETURN NIL
FUNCTION Main()
   LOCAL i, baseline
   Exercise()
   baseline := hb_memcheck()
   FOR i := 1 TO 100
      Exercise()
   NEXT
   ? retained[1], Len(retained), Len(retained[2]), "pending", hb_memcheck()-baseline
RETURN NIL

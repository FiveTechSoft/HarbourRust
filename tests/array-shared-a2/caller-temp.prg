FUNCTION Touch(p, q)
   LOCAL i
   FOR i := 1 TO 20
      AAdd(p,i)
   NEXT
RETURN Len(p) + q
FUNCTION Make()
   LOCAL a := {}, b := a
   AAdd(b,1)
RETURN a
FUNCTION Work()
   LOCAL a := {}, b := a, n
   n := Touch( Make(), Touch( Make(), 0 ) )
   IF n != 42
      Break("caller argument root")
   ENDIF
RETURN NIL
FUNCTION Main()
   LOCAL i, baseline
   Work()
   baseline := hb_memcheck()
   FOR i := 1 TO 100
      Work()
   NEXT
   ? "pending", hb_memcheck()-baseline
RETURN NIL

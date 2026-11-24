FUNCTION Replace(p)
   AAdd(p,"before")
   p := {}
   AAdd(p,"after")
RETURN p
FUNCTION Exercise()
   LOCAL a := {}, b := a, c
   c := Replace(a)
   IF Len(a) != 1 .OR. a[1] != "before" .OR. c[1] != "after"
      Break("rebind")
   ENDIF
   a := {"new"}
   IF b[1] != "before" .OR. a[1] != "new"
      Break("local rebind")
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

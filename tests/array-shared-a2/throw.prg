FUNCTION Make()
   LOCAL a := {}, b := a
   AAdd(a, "exception")
   AAdd(b, a)
   Break(a)
RETURN NIL
FUNCTION Exercise()
   LOCAL a, b
   TRY
      Make()
   CATCH a
      b := a
      IF Len(b) != 2 .OR. b[1] != "exception" .OR. Len(b[2]) != 2
         Break("catch")
      ENDIF
   END
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

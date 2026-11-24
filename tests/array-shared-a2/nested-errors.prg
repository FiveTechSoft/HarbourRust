FUNCTION Fails()
   Break("expected")
RETURN 1
FUNCTION Exercise()
   LOCAL a := {}, b := a, caught := 0, c := {{1}}
   AAdd(a,c)
   TRY
      b[1][Fails()] := "prefix" + Str(1,2)
   CATCH
      caught++
   END
   TRY
      b[1][99] := "prefix" + Str(1,2)
   CATCH
      caught++
   END
   TRY
      b[1][Fails()] := 2.5
   CATCH
      caught++
   END
   IF caught != 3 .OR. b[1][1][1] != 1
      Break("errors")
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

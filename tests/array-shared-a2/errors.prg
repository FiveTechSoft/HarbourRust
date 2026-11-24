FUNCTION Fails()
   Break("expected")
RETURN 1
FUNCTION Exercise()
   LOCAL a := {}, b := a, caught := 0
   AAdd(a, "initial")
   TRY
      b[Fails()] := "prefix" + Str(1,2)
   CATCH
      caught++
   END
   TRY
      b[100] := "prefix" + Str(1,2)
   CATCH
      caught++
   END
   TRY
      b[Fails()] := 2.5
   CATCH
      caught++
   END
   b := NIL
   TRY
      AAdd(b, "owned"+Str(1,2))
   CATCH
      caught++
   END
   b := a
   IF caught != 4 .OR. b[1] != "initial"
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

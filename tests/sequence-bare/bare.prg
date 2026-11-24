// Own MIT. No RECOVER consumes BREAK, even inside a recovering sequence.
FUNCTION Fail(x)
 BREAK "payload"+hb_ntos(x)
RETURN NIL
PROCEDURE Work()
 LOCAL i:=0,e:=NIL
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   ? "normal",i
  END SEQUENCE
  BEGIN SEQUENCE
   ? "before"
   BREAK
   ? "never"
  END SEQUENCE
  ? "after"
  BEGIN SEQUENCE
   BEGIN SEQUENCE
    Fail(i)
   END SEQUENCE
   ? "after-nested"
  RECOVER USING e
   ? "never-outer",e
  END SEQUENCE
  BEGIN SEQUENCE
   BEGIN SEQUENCE
    BREAK "discarded"
   END SEQUENCE
   BREAK "actual"
  RECOVER USING e
   ? "caught",e
  END SEQUENCE
 NEXT
RETURN
PROCEDURE Main()
 Work()
RETURN

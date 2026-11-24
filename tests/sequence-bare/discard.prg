// Own MIT. More than the exception stack capacity, discarded owned values.
FUNCTION Text()
RETURN AllTrim("  discarded owned value  ")
PROCEDURE Work()
 LOCAL i:=0,e:=NIL
 FOR i:=1 TO 513
  BEGIN SEQUENCE
   BREAK Text()
  END SEQUENCE
  BEGIN SEQUENCE
   BEGIN SEQUENCE
    BREAK Text()
   END SEQUENCE
   BREAK i
  RECOVER USING e
   ? e
  END SEQUENCE
 NEXT
RETURN
PROCEDURE Main()
 Work()
RETURN

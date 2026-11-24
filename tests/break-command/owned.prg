// Own MIT. Existing Break ownership path, new command spelling.
FUNCTION MakeText()
RETURN AllTrim("  owned payload  ")
PROCEDURE Work()
 LOCAL e:=NIL,s:="",i:=0
 FOR i:=1 TO 117
  s:=MakeText()
  BEGIN SEQUENCE
   BREAK s
  RECOVER USING e
   ? e
  END SEQUENCE
  BEGIN SEQUENCE
   BEGIN SEQUENCE
    BREAK MakeText()
   RECOVER USING e
    ? "inner",e
   END SEQUENCE
   BREAK "outer"
  RECOVER USING e
   ? "outer",e
  END SEQUENCE
  s:=MakeText()
 NEXT
RETURN
PROCEDURE Main()
 Work()
RETURN

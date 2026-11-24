// Own MIT. BREAK(function syntax) retains owned payload across unwinding.
FUNCTION tb_owned()
 LOCAL s:=AllTrim(" owned ")
 Break(s)
PROCEDURE Main()
 LOCAL i:=0,e:=NIL
 FOR i:=1 TO 513
  BEGIN SEQUENCE
   tb_owned()
  RECOVER USING e
   ? e
  END SEQUENCE
 NEXT
RETURN

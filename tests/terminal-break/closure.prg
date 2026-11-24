// Own MIT. Next ordinary/static function and EOF remain visible.
FUNCTION tb_first(x)
 BREAK x+1
STATIC FUNCTION tb_second()
 BREAK "second"
PROCEDURE tb_work()
 LOCAL i:=0,e:=NIL
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   tb_first(i)
  RECOVER USING e
   ? e
  END SEQUENCE
  BEGIN SEQUENCE
   tb_second()
  RECOVER USING e
   ? e
  END SEQUENCE
  BEGIN SEQUENCE
   tb_last()
  RECOVER USING e
   ? ValType(e)
  END SEQUENCE
 NEXT
RETURN
PROCEDURE Main()
 tb_work()
RETURN
FUNCTION tb_last()
 BREAK

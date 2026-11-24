// Own MIT: statically string operands take a separate comparison route.
FUNCTION Main()
 LOCAL a:=AClone({17}),e,n:=0,i
 FOR i:=1 TO 17
  BEGIN SEQUENCE
   ? a==19.25
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? 19.25==a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a==Space(3)
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? Space(3)==a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a=="x"
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? "x"==a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a=="x"
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? "x"==a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

// Own MIT: array ordering against statically logical operands.
FUNCTION Main()
 LOCAL a:=AClone({17}),e,n:=0,i,l:=.T.
 FOR i:=1 TO 37
  BEGIN SEQUENCE
   ? a<.T.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a<=.T.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>.T.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>=.T.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .T.<a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .T.<=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .T.>a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .T.>=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a<.F.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a<=.F.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>.F.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>=.F.
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .F.<a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .F.<=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .F.>a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? .F.>=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a<l
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a<=l
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>l
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? a>=l
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? l<a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? l<=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? l>a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   ? l>=a
  RECOVER USING e
   ? e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

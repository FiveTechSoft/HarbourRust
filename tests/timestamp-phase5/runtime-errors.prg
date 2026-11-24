FUNCTION CheckValue(x)
RETURN Empty(x)
FUNCTION Main()
 LOCAL a:={},t:=hb_SToT("20261123"),i,e,n:=0
 AAdd(a,t)
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   CheckValue(a)
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   IF Empty(a)
    n+=1000
   ENDIF
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

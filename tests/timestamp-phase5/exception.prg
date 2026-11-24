FUNCTION FailValue()
 Break("stop")
RETURN hb_SToT("")
FUNCTION Main()
 LOCAL t:=hb_SToT("20261123"),i,e,n:=0
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   IF Empty(FailValue())
    n+=1000
   ENDIF
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

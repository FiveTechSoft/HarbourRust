FUNCTION FailStamp()
 Break("stop")
RETURN hb_SToT("")
FUNCTION MakeStamp()
RETURN hb_SToT("20261123101530987")
FUNCTION Main()
 LOCAL i,e,n:=0
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   IF MakeStamp()<FailStamp()
    n+=1000
   ENDIF
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,MakeStamp()==MakeStamp()
RETURN NIL

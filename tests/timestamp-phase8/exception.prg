#include "hbclass.ch"
CLASS Entry
 DATA stamp
 METHOD Put(x)
ENDCLASS
METHOD Put(x) CLASS Entry
 ::stamp:=x
RETURN Self
FUNCTION FailStamp()
 Break("stop")
RETURN hb_SToT("")
FUNCTION Main()
 LOCAL o:=Entry():New(),t:=hb_SToT("20261123"),i,e,n:=0
 o:Put(t)
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   o:Put(FailStamp())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,ValType(o:stamp),hb_TToS(o:stamp)
RETURN NIL

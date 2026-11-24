FUNCTION Less(a,b)
RETURN a<b
FUNCTION Same(a,b)
RETURN a==b
FUNCTION TextValue()
RETURN "not timestamp"+Str(1,1)
FUNCTION Main()
 LOCAL i,e,n:=0,t:=hb_SToT("20261123"),a:={}
 AAdd(a,SToD("20261123"))
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   Less(t,a[1])
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   Less(t,1)
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   Less(t,NIL)
  RECOVER USING e
   n++
  END SEQUENCE
  BEGIN SEQUENCE
   Same(t,TextValue())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

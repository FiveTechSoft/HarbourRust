FUNCTION FailDate()
 Break("stop")
RETURN SToD("")
FUNCTION Compare(a,b)
RETURN a<b
FUNCTION Main()
 LOCAL d:=SToD("20261123"),t:=hb_SToT("20261123"),i,e,n:=0
 FOR i:=1 TO 101
  BEGIN SEQUENCE
   Compare(d,FailDate())
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,Compare(d,SToD("20261124"))
RETURN NIL

FUNCTION Work()
 LOCAL i,n:=0
 FOR i:=1 TO 117
  n+=Len({"word",{19.25,SToD("20040229")}})+Len({})+Len({1,2})
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

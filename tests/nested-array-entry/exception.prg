FUNCTION Fail()
 Break("stop")
RETURN 1
FUNCTION Main()
 LOCAL a:={{NIL,"safe"}},e,i,n:=0
 FOR i:=1 TO 117
  BEGIN SEQUENCE
   a[Fail(),1]:=Replicate("word",31)
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1,1],a[1,2]
RETURN NIL

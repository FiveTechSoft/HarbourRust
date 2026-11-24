FUNCTION Work()
 LOCAL a:={1,"text"}
 a[1]:=a
 a[2]:=Replicate("word",31)
 Break("stop")
RETURN NIL
FUNCTION Main()
 LOCAL i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   Work()
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n
RETURN NIL

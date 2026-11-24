FUNCTION Put(a,x)
 a[1]:=x
 Break("stop")
RETURN NIL
FUNCTION Main()
 LOCAL a:={1,"old"},i,e,n:=0
 FOR i:=1 TO 157
  BEGIN SEQUENCE
   Put(a,Replicate("word",31))
  RECOVER USING e
   n++
  END SEQUENCE
 NEXT
 ? n,a[1],a[2]
RETURN NIL

FUNCTION Work()
 LOCAL a:={1,"old"},i
 FOR i:=1 TO 117
  a[2]:={"top",{"leaf",NIL}}
 NEXT
RETURN 4
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

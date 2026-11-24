FUNCTION Work()
 LOCAL a:={{NIL}},b:={{"top",{"leaf",{"deep",{"four",""}}}}},i,n:=0
 a[1,1]:=1
 FOR i:=1 TO 117
  n+=Len(b[1,2,1])+Len(b[1,2,2,1])+Len(b[1,2,2,2])
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

FUNCTION Work()
 LOCAL a:={{NIL}},b:={{"top",{"leaf",{"deep",{"four",""}}}}},i,c
 a[1,1]:=1
 FOR i:=1 TO 117
  c:=ValType(b[1,2])+ValType(b[1,2,2])+ValType(b[1,2,2,2])
 NEXT
RETURN c
FUNCTION Main()
 LOCAL i,c
 FOR i:=1 TO 37
  c:=Work()
 NEXT
 ? c
RETURN NIL

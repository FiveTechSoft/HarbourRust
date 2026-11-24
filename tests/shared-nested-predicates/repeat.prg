FUNCTION Work()
 LOCAL a:={{NIL}},b:={{"top",{"leaf",{"deep",{"four",19.25}}}}},i,n:=0
 a[1,1]:=1
 FOR i:=1 TO 117
  IF HB_ISARRAY(b[1,2]).AND.HB_ISARRAY(b[1,2,2]).AND.HB_ISNUMERIC(b[1,2,2,2])
   n++
  ENDIF
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

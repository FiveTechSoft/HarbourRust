FUNCTION Work()
 LOCAL a:=AClone({19.25}),i,n:=0
 FOR i:=1 TO 117
  IF HB_ISNUMERIC(a[1]).AND.!HB_ISARRAY(a[1])
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

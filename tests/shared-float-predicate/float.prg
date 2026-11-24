FUNCTION Main()
 LOCAL a:=AClone({17,"word",19.25,.T.,NIL,SToD("20040229"),{}}),i,c
 FOR i:=1 TO 7
  ? HB_ISNUMERIC(a[i]),HB_ISARRAY(a[i])
 NEXT
 FOR i:=1 TO 3
  c:=IIF(HB_ISNUMERIC(a[i]),HB_NToS(a[i]),a[i])
  ? "["+c+"]",Len(c)
 NEXT
RETURN NIL

FUNCTION Main()
 LOCAL a:=AClone({17,"word",23}),i,c
 FOR i:=1 TO 3
  c:=IIF(HB_ISNUMERIC(a[i]),HB_NToS(a[i]),a[i])
  ? c
  c:=IIF(!HB_ISNUMERIC(a[i]),a[i],HB_NToS(a[i]))
  ? c
 NEXT
 ? a[1],a[2],a[3]
RETURN NIL

FUNCTION Main()
 LOCAL a:={2.5,"a",NIL,.T.,{},SToD("20260101")},i
 FOR i:=1 TO 211
  ASort(a,NIL,NIL,{||"nonlogical"})
 NEXT
 ? a[1],a[2],ValType(a[3]),a[4],Len(a[5]),a[6]
RETURN NIL

FUNCTION Main()
 LOCAL a:={SToD("20260102"),SToD(""),SToD("20240229"),SToD("20260101")},i
 ASort(a)
 FOR i:=1 TO Len(a)
  ? DToS(a[i])
 NEXT
RETURN NIL

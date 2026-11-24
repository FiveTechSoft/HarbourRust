FUNCTION Main()
 LOCAL a:={1.25,-3,2.5},i
 ASort(a)
 FOR i:=1 TO 317
  a:={3.25,-1.5,0,19.125}
  a[1]:=i/3
  ASort(a)
 NEXT
 ? a[2],a[3]
RETURN NIL

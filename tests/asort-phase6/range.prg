FUNCTION Main()
 LOCAL a:={NIL,9,.T.,"x",{1},SToD("20260101"),.F.,-1.5,"a",{},NIL},i
 ASort(a,2,8)
 FOR i:=1 TO Len(a)
  ? ValType(a[i])
 NEXT
 ? a[3],a[4],a[5],a[6],a[7],a[8],a[9]
RETURN NIL

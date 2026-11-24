FUNCTION Main()
 LOCAL a:={NIL,3,.T.,"s",{8},SToD("20260101"),.F.,-2.25,"a",{}},b
 b:=SortIt(a)
 ? Len(a[1]),a[1][1],Len(a[2]),a[3],a[4],a[5],a[6],a[7],a[8],a[9],ValType(a[10])
 ? Len(b),Len(a)
RETURN NIL
FUNCTION SortIt(p)
 ASort(p)
RETURN p

FUNCTION Main()
 LOCAL a:={7,"b",NIL,.T.,SToD("20260102"),{7},-2.5,"a",.F.,NIL,{},SToD("20250102"),0},i
 ASort(a)
 ? Len(a[1]),a[1][1],Len(a[2])
 ? a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11]
 ? ValType(a[12]),ValType(a[13])
 ASort(a)
 ? Len(a[1]),a[1][1],Len(a[2]),a[7],a[8]
RETURN NIL

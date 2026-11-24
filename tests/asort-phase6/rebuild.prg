FUNCTION Main()
 LOCAL a:={2,"b",.T.,SToD("20260101"),NIL,{}},b:=a
 ASort(a)
 a:={{7},SToD(""),.F.,2.75,"z",NIL}
 ASort(a)
 ? Len(a[1]),a[1][1],a[2],a[3],a[4],a[5],ValType(a[6])
 ? Len(b[1]),b[2],b[3],b[4],b[5],ValType(b[6])
RETURN NIL

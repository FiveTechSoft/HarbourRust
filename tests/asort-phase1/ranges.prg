FUNCTION Main()
 LOCAL a:={9,7,5,3,1},i
 ASort(a,2,2)
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,-3)
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,0,0)
 ? a[1],a[2],a[3],a[4],a[5]
 a:={9,7,5}
 ASort(a,8,5)
 ? a[1],a[2],a[3]
 ASort(a,NIL,NIL)
 ? a[1],a[2],a[3]
RETURN NIL

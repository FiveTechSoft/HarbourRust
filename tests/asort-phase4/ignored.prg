FUNCTION Main()
 LOCAL a:={7,2,9,1}
 ASort(a,NIL,NIL,Replicate("unused",7))
 ? a[1],a[4]
 ASort(a,2,2,42)
 ? a[1],a[4]
RETURN NIL

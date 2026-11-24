FUNCTION Main()
 LOCAL a:={7,-2,4,0,7},b:={"prefix-long","","prefix","A","a"}
 ASort(a)
 ASort(b)
 ? a[1],a[2],a[3],a[4],a[5]
 ? "["+b[1]+"]",b[2],b[3],b[4],b[5]
RETURN NIL

FUNCTION Main()
 LOCAL a:={6,2,8,2,9,1,6}
 ASort(a,NIL,NIL,{|x,y|QOut(x,y),7})
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7]
 ASort(a,2,4,{|x,y|QOut(x,y),NIL})
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7]
RETURN NIL

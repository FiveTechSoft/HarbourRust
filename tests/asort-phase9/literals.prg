FUNCTION Main()
 LOCAL a:={3,1,2,5,4}
 ASort(a,NIL,NIL,{||NIL})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{||0})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{||-7})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{||"x"})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{|x|""})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{|x,y|x<y})
 ? a[1],a[2],a[3],a[4],a[5]
RETURN NIL

FUNCTION Main()
 LOCAL a:={3,1,2,5,4}
 ASort(a,NIL,NIL,{|x,y|QOut(x,y),.F.})
 ? a[1],a[2],a[3],a[4],a[5]
 ASort(a,NIL,NIL,{|x,y|QOut(x,y),.T.})
 ? a[1],a[2],a[3],a[4],a[5]
RETURN NIL

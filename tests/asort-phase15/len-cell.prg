FUNCTION Main()
 LOCAL a:={{"pear",3,{}},{"fig",2,{1}}}
 ASort(a,NIL,NIL,{|x,y|x[2]<y[2]})
 ? Len(a[1][1]),Len(a[2][1]),Len(a[1][3]),Len(a[2][3])
RETURN NIL

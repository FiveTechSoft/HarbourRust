FUNCTION Main()
 LOCAL a:={9,8,7,6,5,4,3,2,1}
 ASort(a,3,4,{|x,y|QOut(x,y),x<y})
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]
 ASort(a,-1,4,{|x,y|QOut("BAD"),x<y})
 ASort(a,99,4,{|x,y|QOut("BAD"),x<y})
 ASort(a,0,2,{|x,y|QOut(x,y),x>y})
 ASort(a,6,0,{|x,y|QOut(x,y),x<y})
 ? a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9]
RETURN NIL

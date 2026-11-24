STATIC s:=""
FUNCTION Record(a,b)
 s += hb_ntos(a)
RETURN a<b
FUNCTION Main()
 LOCAL a:={3,1,2},n:=1
 ASort(a,NIL,NIL,{|x,y|Record(x,n)})
RETURN NIL

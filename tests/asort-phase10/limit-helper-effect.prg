STATIC s:=""
FUNCTION Record(a,b)
 s += hb_ntos(a)
 QOut(a)
RETURN a<b
FUNCTION Main()
 LOCAL a:={3,1,2}
 ASort(a,NIL,NIL,{|x,y|Record(x,y)})
RETURN NIL

FUNCTION Unknown(x,y,n)
 Break("stop")
RETURN x<y
FUNCTION Main()
 LOCAL a:={2,1},n:=1
 ASort(a,NIL,NIL,{|x,y|Unknown(x,y,n)})
RETURN NIL

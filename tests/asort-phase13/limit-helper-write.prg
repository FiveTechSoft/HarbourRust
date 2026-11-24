FUNCTION Cell(a,n)
 a[1]:=99
RETURN a[n]
FUNCTION Main()
 LOCAL a:={{1},{2}},n:=1
 ASort(a,NIL,NIL,{|x,y|Cell(x,n)<Cell(y,n)})
RETURN NIL

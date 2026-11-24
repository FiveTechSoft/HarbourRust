FUNCTION Cell(a,n)
RETURN a[n]
FUNCTION Cmp(x,y)
RETURN iif(x<y,-1,iif(x>y,1,0))
FUNCTION SortRows(a,k,desc)
 LOCAL n:=0,l:=.F.
 n+=k
 IF desc
  l:=.T.
 ENDIF
 ASort(a,NIL,NIL,{|x,y|iif(l,Cmp(Cell(y,n),Cell(x,n)),Cmp(Cell(x,n),Cell(y,n)))<0})
RETURN a
FUNCTION Main()
 LOCAL a:={{"p",2,1.25},{"u",1,0.5},{"k",3,2.5}},i,j
 FOR j:=1 TO 59
  SortRows(a,2,.F.)
  SortRows(a,3,.T.)
 NEXT
 FOR i:=1 TO Len(a)
  ? a[i][1],a[i][2],a[i][3]
 NEXT
RETURN NIL

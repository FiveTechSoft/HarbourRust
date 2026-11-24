FUNCTION TouchRow(x,y)
 x[1]:=99
RETURN x[1]<y[1]
FUNCTION Main()
 LOCAL rows:={{2,1},{1,2}}
 ASort(rows,NIL,NIL,{|x,y|TouchRow(x,y)})
 ? rows[1][1]
RETURN NIL

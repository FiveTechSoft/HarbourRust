STATIC calls:=0
FUNCTION CompareOrFail(x,y,limit)
 calls++
 x[1]:=7
 IF calls>limit
  Break("expected")
 ENDIF
RETURN x<y
FUNCTION Main()
 LOCAL a:={{2},{1}},n:=1
 ASort(a,NIL,NIL,{|x,y|CompareOrFail(x,y,n)})
RETURN NIL

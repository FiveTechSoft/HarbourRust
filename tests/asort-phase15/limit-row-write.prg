STATIC calls:=0
FUNCTION CompareOrFail(x,y,n)
 calls++
 x[1]:=7
 IF calls>n
  Break("expected")
 ENDIF
RETURN x[1]<y[1]
FUNCTION Main()
 LOCAL a:={{2},{1}},n:=1
 ASort(a,NIL,NIL,{|x,y|CompareOrFail(x,y,n)})
RETURN NIL

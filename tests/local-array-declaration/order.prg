PROCEDURE Main()
 LOCAL x:=0,a[NextDim(@x),NextDim(@x)],b[(1+2)],i:=0
 ? x,Len(a),Len(a[1]),Len(b),ValType(a[1,1])
RETURN
FUNCTION NextDim(x)
 x++
 ? "dimension",x
RETURN x

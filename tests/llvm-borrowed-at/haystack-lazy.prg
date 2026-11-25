FUNCTION Main()
LOCAL a:={1},n:=0,k:=9223372036854775807
? At("x",IIf(.T.,"x",IIf(a[99]==1,"bad","x")))
? At("x",IIf(.F.,IIf(++k>0,"bad",""),"ax")),k
? At("x",IIf(++n==1,IIf(++n==2,"xx",""),"bad")),n
? At("x",IIf(.T.,"x",""))==1
RETURN NIL

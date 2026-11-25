FUNCTION Main()
LOCAL a:={1},n:=0,bad:=99,k:=9223372036854775807
? Rat("x",IIf(.T.,"x",IIf(a[bad]==1,"bad","x")))
? Rat("x",IIf(.F.,IIf(++k>0,"bad",""),"ax")),k
? Rat("x",IIf(++n==1,IIf(++n==2,"xx",""),"bad")),n
? Rat("x",IIf(.T.,"x",""))==1
RETURN NIL

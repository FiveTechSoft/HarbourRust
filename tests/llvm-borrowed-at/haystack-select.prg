FUNCTION Main()
LOCAL a:="ab",b:="xy",n:=0
? At(a,IIf(++n==1,"zabxy","bad")),n
? At("b",IIf(.T.,"aba","bb"))
? At(Chr(0),IIf(.F.,"",IIf(.T.,"a"+Chr(0),"x"))),n
? At("",IIf(++n==2,"abc","")),n
? At("long",IIf(.T.,"x","long")),At("中",IIf(.T.,"é中",""))
RETURN NIL

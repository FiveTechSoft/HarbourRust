FUNCTION Main()
LOCAL a:="ab",b:="xy",n:=0
? Rat(a,IIf(++n==1,"zabxy","bad")),n
? Rat("aa",IIf(.T.,"aaaa","aa")),Rat("b",IIf(.T.,"aba","bb"))
? Rat(Chr(0),IIf(.F.,"",IIf(.T.,"a"+Chr(0),"x"))),n
? Rat("",IIf(++n==2,"abc","")),n
? Rat("long",IIf(.T.,"x","long")),Rat("中",IIf(.T.,"é中",""))
RETURN NIL

FUNCTION Main()
LOCAL s:="Abcd",t:="9z",n:=0,b:=IsAlpha(s)
? b,IsUpper(s),IsLower(s),IsDigit(t)
IF IsUpper(s).AND.IsDigit(t)
 n++
ENDIF
? n,IIf(IsLower(s),11,22),Empty(IsAlpha(s))
? IsAlpha("A"+Chr(0)),IsDigit(Chr(48)+"tail")
RETURN NIL

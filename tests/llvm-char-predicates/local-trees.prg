FUNCTION Main()
LOCAL a:="A",b:="",c:="9",d:="z",n:=0
? IsAlpha(b+a),IsUpper(a+"x"),IsLower(a+d),IsDigit(b+c)
? IsAlpha(b+b),IsUpper(b+b),IsLower(b+b),IsDigit(b+b)
? IsAlpha(Chr(0)+a),IsDigit(Chr(0)+c),IsAlpha(b+"?"),IsDigit(a+c)
? IsLower(b+d),IsUpper(b+d),IsAlpha(a+"é"),IsDigit(c+"中")
IF IsUpper(b+a).AND.IsLower(b+d).AND.IsDigit(b+c)
 n++
ENDIF
? n,IIf(IsDigit(b+c),17,99),Empty(IsAlpha(b+b))
RETURN NIL

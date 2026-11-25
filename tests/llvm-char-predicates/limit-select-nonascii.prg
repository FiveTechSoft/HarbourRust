FUNCTION Main()
LOCAL a:="A"
? IsAlpha(IIf(.T.,a+"",IIf(.F.,a+"","é")))
RETURN NIL

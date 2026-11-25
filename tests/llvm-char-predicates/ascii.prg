FUNCTION Main()
? IsDigit(""),IsAlpha(""),IsUpper(""),IsLower("")
? IsDigit("0"),IsDigit("9x"),IsDigit("/"),IsDigit(":"),IsDigit("a0")
? IsAlpha("A"),IsAlpha("Z"),IsAlpha("a"),IsAlpha("z"),IsAlpha("["),IsAlpha("`")
? IsUpper("A"),IsUpper("Z"),IsUpper("a"),IsUpper("@")
? IsLower("a"),IsLower("z"),IsLower("A"),IsLower("{")
? IsDigit(Chr(0)),IsAlpha(Chr(127)),IsUpper(Chr(9)),IsLower(Chr(32))
RETURN NIL

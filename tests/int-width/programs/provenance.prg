FUNCTION Same(x)
RETURN x
FUNCTION Main()
 LOCAL x := 9007199254740993, y := Int(9007199254740993)
 ? "literal", 9007199254740993
 ? "int-lit", Int(9007199254740993)
 ? "local", x
 ? "int-local", Int(x)
 ? "stored-int", y
 ? "folded", Int(9007199254740992+1)
 ? "call", Same(9007199254740993)
 ? "int-call", Int(Same(9007199254740993))
 ? "small", Int(123), Int(12345678901)
 ? "negative", Int(-9007199254740993)
RETURN NIL

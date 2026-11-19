FUNCTION Same(x)
RETURN x
FUNCTION Main()
 LOCAL d, n := 9007199254740993, r
 d := Same(n+1)
 ? "runtime", d, Int(d)
 d := Same(12345678901)
 ? "literal", d, Int(d), Int(Int(d))
 d := Same(-12345678901)
 ? "negative", d, Int(d)
 r := Int(d)
 ? "stored", r
RETURN NIL

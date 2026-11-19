FUNCTION Same(x)
RETURN x
FUNCTION Main()
 LOCAL n := 12345678901, f := 1.5, d
 d := Same(9007199254740993)
 ? "runtime", n+1, Int(n+1)
 ? "negative", -12345678901, Int(-12345678901)
 ? "float", Int(f), Int(-2.75)
 ? "nested", Int(Int(9007199254740993))
 ? "values", Str(Int(9007199254740993)), Str(Int(-2.75))
RETURN NIL

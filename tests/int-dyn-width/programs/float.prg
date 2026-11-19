FUNCTION Same(x)
RETURN x
FUNCTION Main()
 LOCAL d
 d := Same(1.5)
 ? "positive", Int(d), Str(Int(d))
 d := Same(-2.75)
 ? "negative", Int(d), Str(Int(d))
 ? "owned", Int(Same(1.5))
RETURN NIL

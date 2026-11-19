FUNCTION Same(x)
RETURN x
FUNCTION Main()
 LOCAL d, r
 d := Same(9007199254740993)
 ? "dyn", d
 ? "int", Int(d)
 r := Int(d)
 ? "stored", r
 ? "owned", Int(Same(9007199254740993))
 d := Same(9007199254740993+1)
 ? "computed", d, Int(d)
 d := Same(-9007199254740993)
 ? "negative", d, Int(d)
RETURN NIL

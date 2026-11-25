STATIC n
FUNCTION Main()
? ValType(n), n
n := 9
? n, Value()
n := .T.
? n, Value()
n := NIL
? ValType(n)
RETURN NIL
FUNCTION Value()
RETURN n

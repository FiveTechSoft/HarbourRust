STATIC n, m
FUNCTION Main()
LOCAL x
n := 12
m := n
n := .F.
x := m
? x, m, n
m := NIL
? x, ValType(m)
RETURN NIL

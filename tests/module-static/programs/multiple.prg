STATIC n := -3, m := 4
PROCEDURE Main()
? n,m
Swap()
? n,m
RETURN
FUNCTION Swap()
LOCAL t := n
n := m
m := t
RETURN NIL

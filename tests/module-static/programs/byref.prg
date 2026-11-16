STATIC n := 7
PROCEDURE Main()
Bump(@n)
? n,ReadN()
RETURN
FUNCTION Bump(x)
x := x+1
RETURN NIL
FUNCTION ReadN()
RETURN n

STATIC n := 0
PROCEDURE Main()
? Recur(3),n
RETURN
FUNCTION Recur(d)
n := n+1
IF d > 0
RETURN Recur(d-1)
ENDIF
RETURN n

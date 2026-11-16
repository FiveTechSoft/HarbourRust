STATIC n := 7
PROCEDURE Main()
? ReadN(), Shadow(), Shadow(), ReadN()
RETURN
FUNCTION ReadN()
RETURN n
FUNCTION Shadow()
STATIC n := 20
n := n+1
RETURN n

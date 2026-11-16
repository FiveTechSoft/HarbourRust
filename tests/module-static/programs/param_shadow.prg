STATIC n := 7
PROCEDURE Main()
? ReadN(), Shadow(20), ReadN()
RETURN
FUNCTION ReadN()
RETURN n
FUNCTION Shadow(n)
n := n+1
RETURN n

STATIC n := 7
PROCEDURE Main()
? ReadN(), Shadow(), ReadN()
RETURN
FUNCTION ReadN()
RETURN n
FUNCTION Shadow()
LOCAL n := 20
n := n+1
RETURN n

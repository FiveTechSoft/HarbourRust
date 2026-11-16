STATIC n := 1
PROCEDURE Main()
LOCAL x := 20
? Advance(@n),n
? Advance(@x),x,n
? Advance(@n),n
RETURN
FUNCTION Advance(value)
value := value+1
n := n+10
RETURN value

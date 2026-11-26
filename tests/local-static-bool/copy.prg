PROCEDURE Main()
F()
F()
RETURN
PROCEDURE F()
STATIC n:=.T.
LOCAL x:=n
? Mutate(n),x,n,ValType(n)
n:=.F.
RETURN
FUNCTION Mutate(x)
x:=!x
RETURN x

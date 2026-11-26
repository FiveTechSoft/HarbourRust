STATIC n:=1.2500
PROCEDURE Main()
LOCAL x:=n
n:=2.50
? x,n
n:=Mutate(n)
? x,n
RETURN
FUNCTION Mutate(x)
x:=x+4.000
RETURN x

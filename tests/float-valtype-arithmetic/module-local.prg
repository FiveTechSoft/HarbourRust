STATIC n:=1.25
PROCEDURE Main()
? ValType(n+2.5),F(),F()
RETURN
FUNCTION F()
STATIC x:=2.5
x+=1.25
RETURN ValType(x*n)

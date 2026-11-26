PROCEDURE Main()
LOCAL n:=1.25
? ValType(n),F(n),n
RETURN
FUNCTION F(x)
? ValType(x),x
x:=2.50
RETURN ValType(x)

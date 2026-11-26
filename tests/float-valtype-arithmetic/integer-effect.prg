STATIC n:=0
PROCEDURE Main()
? ValType(F()+1.25),n
RETURN
FUNCTION F()
n+=1
? "integer",n
RETURN 2

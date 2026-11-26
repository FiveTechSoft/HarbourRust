STATIC n:=0
PROCEDURE Main()
? "pending",ValType(F()+G()*2),n
RETURN
FUNCTION F()
n:=n*10+1
? "left",n
RETURN 2
FUNCTION G()
n:=n*10+2
? "right",n
RETURN 3

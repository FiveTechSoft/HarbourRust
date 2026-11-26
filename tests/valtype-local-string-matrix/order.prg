STATIC n:=0
PROCEDURE Main()
? "pending",ValType(F()),n
RETURN
FUNCTION F()
? "callee"
n+=1
RETURN 2.50

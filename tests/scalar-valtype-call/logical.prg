STATIC n:=0
PROCEDURE Main()
? "pending",ValType(F()),n
? ValType(F()),n
RETURN
FUNCTION F()
n+=1
? "callee",n
RETURN n>1

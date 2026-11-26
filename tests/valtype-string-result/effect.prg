STATIC n:=0
PROCEDURE Main()
LOCAL s:=Space(8)
? "pending",ValType(G(s)),s,n
RETURN
FUNCTION G(s)
n+=1
? "callee",n
RETURN s+"x"

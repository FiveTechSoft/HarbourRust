PROCEDURE Main()
LOCAL s:=Space(8)
? ValType(F(s)+H(s)),s
RETURN
FUNCTION F(s)
? "float",s+""
RETURN 1.25
FUNCTION H(s)
? "int",s+""
RETURN 2

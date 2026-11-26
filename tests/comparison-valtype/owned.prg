PROCEDURE Main()
LOCAL s:=Space(8)
? ValType(F(s)==G(s)),s
RETURN
FUNCTION F(s)
? s+""
RETURN s
FUNCTION G(s)
? s+""
RETURN s+"x"

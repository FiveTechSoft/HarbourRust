PROCEDURE Main()
LOCAL s:=Space(8)
? ValType(F(G(s))),s
RETURN
FUNCTION G(s)
? "inner",s+""
RETURN s+"g"
FUNCTION F(s)
? "outer",s+""
RETURN 1.25

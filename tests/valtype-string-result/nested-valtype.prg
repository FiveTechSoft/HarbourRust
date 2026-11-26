PROCEDURE Main()
LOCAL s:=Space(8)
? ValType(F(ValType(F(s)))),s
RETURN
FUNCTION F(s)
? s+""
RETURN 1.25

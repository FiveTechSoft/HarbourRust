PROCEDURE Main()
LOCAL s:=Space(9)
? ValType(F(s)+G(s)),s
RETURN
FUNCTION F(s)
s:=s+"a"
? s
RETURN 2.5
FUNCTION G(s)
? s+""
RETURN 1.25

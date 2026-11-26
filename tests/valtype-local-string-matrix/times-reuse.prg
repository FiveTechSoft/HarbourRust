PROCEDURE Main()
LOCAL s:="hello"
? ValType(F(s)*1.25)
? s
RETURN
FUNCTION F(s)
? s+""
RETURN 2.5

PROCEDURE Main()
LOCAL s:="hello"
? ValType(F(s)-1.25)
RETURN
FUNCTION F(s)
? s+""
RETURN 2.5

PROCEDURE Main()
LOCAL s:="hello"
? ValType(F(s))
RETURN
FUNCTION F(s)
? s+""
RETURN .T.

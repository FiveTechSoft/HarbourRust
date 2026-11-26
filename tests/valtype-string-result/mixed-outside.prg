PROCEDURE Main()
LOCAL s:=Space(8),a:={1,2}
? ValType(F(s)),s
? F(a)
RETURN
FUNCTION F(s)
? Len(s)
RETURN 1.25

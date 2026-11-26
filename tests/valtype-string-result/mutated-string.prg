PROCEDURE Main()
LOCAL s:=Space(8)
? ValType(G(s)),s
RETURN
FUNCTION G(s)
s:=s+"x"
RETURN s

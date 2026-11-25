PROCEDURE Main(c)
LOCAL n := 10
? n,ValType(n)
IF !Empty(c)
 n := Val(c)
ENDIF
? n,ValType(n)
n := 7
? n,ValType(n)
RETURN

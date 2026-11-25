PROCEDURE Main(c)
LOCAL n := 0
IF Empty(c)
 c := "0"
ENDIF
n := Val(c)
? n,ValType(n)
n := "old"
? n
n := Val("1.25")
? n,Min(n,2),Max(n,2)
n := NIL
? ValType(n)
n := 11
? n
RETURN

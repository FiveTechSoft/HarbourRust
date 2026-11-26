PROCEDURE Main()
LOCAL s:="hello",i
FOR i:=1 TO 3
? ValType(F(s)*2.5),s
NEXT
RETURN
FUNCTION F(s)
? s+""
RETURN 1.25

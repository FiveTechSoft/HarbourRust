PROCEDURE Main()
LOCAL n:=1.25
Mutate(@n)
? ValType(n)
RETURN
PROCEDURE Mutate(x)
x:=2.5
RETURN

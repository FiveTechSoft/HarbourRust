STATIC a
FUNCTION Main()
LOCAL i:=0
a:=1
FOR i:=1 TO 3 STEP Eval({||Value()})
? i
NEXT
RETURN NIL
FUNCTION Value()
a:=a+1
RETURN a

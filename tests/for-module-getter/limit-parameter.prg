STATIC a,b,c
FUNCTION Main()
LOCAL i:=0
a:=1
b:=4
c:=1
FOR i:=1 TO 3 STEP Eval({|x|StepN()})
? "body",i
NEXT
RETURN NIL
FUNCTION FromN()
? "from"
RETURN a
FUNCTION ToN()
? "to"
RETURN b
FUNCTION StepN()
? "step"
RETURN c

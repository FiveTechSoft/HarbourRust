STATIC a,b,c
FUNCTION Main()
LOCAL i:=0
a:=1
b:=8
c:=1
FOR i:=Eval({||FromN()}) TO Eval({||ToN()}) STEP Eval({||StepN()})
? i
c:=2
b:=5
NEXT
a:=5
b:=1
c:=-2
FOR i:=Eval({||FromN()}) TO Eval({||ToN()}) STEP Eval({||StepN()})
? i
NEXT
RETURN NIL
FUNCTION FromN()
RETURN a
FUNCTION ToN()
RETURN b
FUNCTION StepN()
RETURN c

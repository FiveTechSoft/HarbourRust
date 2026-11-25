PROCEDURE Main()
 LOCAL i:=0,s:=1
 FOR i:=Start() TO Bound() STEP Eval({|| Stepper() })
 ? "body",i
 IF i==2
 LOOP
 ENDIF
 NEXT
 ? "done",i
RETURN
FUNCTION Start()
 ? "start"
RETURN 1
FUNCTION Bound()
 ? "bound"
RETURN 3
FUNCTION Stepper()
 ? "step"
RETURN 1

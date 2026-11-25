PROCEDURE Main()
 LOCAL i,n:=2
 FOR i:=1 TO 3 STEP (StepValue(),2)
  ? i
 NEXT
RETURN
FUNCTION StepValue()
 ? "effect"
RETURN 2

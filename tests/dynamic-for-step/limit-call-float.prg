PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 3 STEP FractionStep()
 ? i
 NEXT
RETURN
FUNCTION FractionStep()
RETURN 1.5

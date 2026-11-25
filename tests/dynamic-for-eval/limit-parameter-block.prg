PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 3 STEP Eval({|s| s},1)
 ? i
 NEXT
RETURN

PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 3 STEP Eval({|| Delta(),1 })
 ? i
 NEXT
RETURN
FUNCTION Delta()
RETURN 1

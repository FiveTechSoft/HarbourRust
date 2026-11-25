PROCEDURE Main()
 LOCAL i:=0
 FOR i:=1 TO 3 STEP Eval({|| Delta() })
 ? i
 NEXT
RETURN
FUNCTION Delta()
RETURN .T.

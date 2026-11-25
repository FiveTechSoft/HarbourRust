PROCEDURE Main()
 LOCAL i:=0,s:=1
 FOR i:=1 TO 3 STEP Eval({|| s })
 ? i
 NEXT
RETURN

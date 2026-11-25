PROCEDURE Main()
 LOCAL i:=0
 FOR i:=First() TO FinalBound() STEP Eval({|| Delta() })
 ? "body",i
 EXIT
 NEXT
 ? "done",i
RETURN
FUNCTION First()
 ? "first"
RETURN 5
FUNCTION FinalBound()
 ? "last"
RETURN 1
FUNCTION Delta()
 ? "delta"
RETURN -1

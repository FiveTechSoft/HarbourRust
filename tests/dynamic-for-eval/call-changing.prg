PROCEDURE Main()
 LOCAL i:=0,n:=0
 FOR i:=1 TO 9 STEP Eval({|| Changing() })
 ? "body",i
 n++
 IF n==5
 EXIT
 ENDIF
 NEXT
 ? "done",i
RETURN
FUNCTION Changing()
 STATIC n:=0
 n++
 ? "step",n
RETURN IIf(n==1,1,2)

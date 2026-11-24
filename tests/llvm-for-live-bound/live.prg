// Own MIT. TO repeated calls and live mutation.
FUNCTION Bound(x)
 ? "bound",x
RETURN x+0
PROCEDURE Main()
 LOCAL i:=0,b:=5
 FOR i:=1 TO Bound(b) STEP (3-2)
  ? "body",i
  IF i==1
   b:=3
   LOOP
  ENDIF
 NEXT
 ? "done",i
 FOR i:=5 TO Bound(1) STEP -(1+1)
  ? "down",i
 NEXT
 ? "done",i
 FOR i:=1 TO Bound(7)
  EXIT
 NEXT
 ? "exit",i
 FOR i:=1 TO Bound(0)
  ? "never"
 NEXT
 ? "skipped",i
 FOR i:=1 TO 5-i
  ? "self",i
 NEXT
 ? "done",i
RETURN

// Own MIT. TO reads live loop state; LOOP rechecks and EXIT does not.
STATIC n:=0
FUNCTION Bound(x)
 n+=1
 ? "test",x,n
RETURN x+0
PROCEDURE Main()
 LOCAL i:=0,b:=5,k:=0
 FOR i:=1 TO Bound(b) STEP (3-2)
  ? "body",i
  IF i==1
   b:=3
   LOOP
  ENDIF
 NEXT
 ? "done",i,n
 FOR i:=1 TO Bound(5) STEP (4/2)
  EXIT
 NEXT
 ? "exit",i,n
 FOR i:=1 TO Bound(0) STEP (6%5)
  ? "never"
 NEXT
 ? "skip",i,n
 FOR i:=1 TO 5-i STEP (2-1)
  ? "self",i
 NEXT
 ? "self-done",i
RETURN

PROCEDURE Main()
 LOCAL i:=0,s:=1,n:=0
 FOR i:=1 TO 3 STEP s
 ? i,s
 n++
 IF n==1
 s:=-1
 ELSE
 EXIT
 ENDIF
 NEXT
 ? "after",i,s
 s:=2
 FOR i:=5 TO 1 STEP s
 ? "bad"
 NEXT
 ? "skipped",i
 s:=-2
 FOR i:=1 TO 5 STEP s
 ? "bad"
 NEXT
 ? "skipped",i
RETURN

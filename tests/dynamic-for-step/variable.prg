PROCEDURE Main()
 LOCAL i:=0,s:=2,j:=0
 FOR i:=1 TO 9 STEP s
 ? i,s
 IF i==3
 s:=3
 ENDIF
 NEXT
 ? "done",i
 s:=-2
 FOR i:=9 TO 1 STEP s
 ? i,s
 NEXT
 ? "descending",i
 s:=0
 FOR i:=1 TO 2 STEP s
 ? "zero",i
 EXIT
 NEXT
 ? i
 FOR j:=1 TO 2
 s:=1
 FOR i:=1 TO 3 STEP s
 ? j,i,s
 IF i==2
 LOOP
 ENDIF
 NEXT
 NEXT
RETURN

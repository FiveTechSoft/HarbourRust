FUNCTION Main()
LOCAL i:=0,s:=0,n:=0
FOR i:=1 TO 3 STEP s
 n++
 ? i,n
 IF n<3
 LOOP
 ENDIF
 EXIT
NEXT
? i,n
RETURN NIL

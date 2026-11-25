PROCEDURE Main()
LOCAL i,n:=0
n:=Val("5.5")
FOR i:=1 TO n
 IF i==2
  LOOP
 ENDIF
 IF i==4
  EXIT
 ENDIF
 ? i
NEXT
? i,n
RETURN

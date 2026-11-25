PROCEDURE Main()
LOCAL i,j,n:=0
n:=Val("2.5")
FOR i:=1 TO n
 FOR j:=3 TO n STEP -1
  ? i,j
 NEXT
NEXT
? i,j,n
RETURN

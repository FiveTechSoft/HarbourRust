PROCEDURE Main()
Recur(3)
Recur(1)
RETURN
PROCEDURE Recur(k)
STATIC n:=1.2500
n+=1.5
IF k>0
Recur(k-1)
ENDIF
? n
RETURN

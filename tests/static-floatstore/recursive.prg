STATIC n:=1.2500
PROCEDURE Main()
Recur(3)
? n
RETURN
PROCEDURE Recur(k)
IF k>0
n:=n+1.50
Recur(k-1)
? n
ENDIF
RETURN

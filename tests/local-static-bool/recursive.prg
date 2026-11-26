PROCEDURE Main()
Recur(3)
Recur(1)
RETURN
PROCEDURE Recur(k)
STATIC n:=.F.
n:=!n
IF k>0
Recur(k-1)
ENDIF
? n
RETURN

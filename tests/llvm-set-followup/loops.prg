FUNCTION Main()
LOCAL n:=0,total:=0,k:=0,b:=.F.
FOR k:=1 TO 4
 total:=(n:=n+2)+total
 ? n,total
NEXT
DO WHILE (n:=n-1)>0
 ? n
ENDDO
FOR k:=1 TO 3
 ? (b:=k>1),b
NEXT
? n,total,b
RETURN NIL

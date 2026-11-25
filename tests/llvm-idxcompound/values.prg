FUNCTION Main()
LOCAL a:={1,2,3,4},n:=0
? (a[1]+=10),(a[2]-=10),(a[3]*=10)
? a[1],a[2],a[3],a[4]
FOR n:=1 TO 4
 a[n]+=n
NEXT
? a[1],a[2],a[3],a[4]
RETURN NIL

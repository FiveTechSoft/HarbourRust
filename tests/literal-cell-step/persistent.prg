FUNCTION Main()
STATIC a
LOCAL i:=0
a:={1,2}
FOR i:=1 TO 10
a[1]++
a[2]--
NEXT
? a[1],a[2]
Mutate(@a)
? a[1],a[2]
RETURN NIL
FUNCTION Mutate(a)
a[1]++
a[2]--
RETURN NIL

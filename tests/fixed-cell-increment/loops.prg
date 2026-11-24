FUNCTION Work()
 LOCAL a:={1,2,3},i,s:=0
 FOR i:=1 TO 151
  s+=a[2]++
  s+=--a[3]
 NEXT
RETURN s+a[2]+a[3]
FUNCTION Show(n)
 ? n
RETURN NIL
FUNCTION Main()
 LOCAL a:={7,9},i,n:=0
 Show(a[1]++)
 Show(++a[1])
 ? a[1]
 FOR i:=1 TO 117
  n+=Work()
 NEXT
 ? n
RETURN NIL

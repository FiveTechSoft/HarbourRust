FUNCTION Work()
 LOCAL a:={{1,"keep"}},b,i:=0,s:=0
 a[1,2]:="safe"
 b:=a
 FOR i:=1 TO 151
  s+=a[1,1]++
  s+=--b[1][1]
 NEXT
RETURN s+a[1,1]
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 117
  n+=Work()
 NEXT
 ? n
RETURN NIL

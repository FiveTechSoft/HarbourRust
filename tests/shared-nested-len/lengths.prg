STATIC n:=0
FUNCTION Ix(i)
 n:=n*10+i
RETURN i
FUNCTION Main()
 LOCAL a:={{NIL}},b:={{"top",{"leaf",{"deep",{"four",""}}}}},c
 a[1,1]:=1
 ? Len(b[1,2,1]),Len(b[1][2,2]),Len(b[1,2,2,1]),Len(b[1][2,2][2])
 ? Len(b[1,2][2,2]),Len(b[1,2,2,2])
 ? Len(b[Ix(1)][Ix(2),Ix(2)][Ix(1)]),n
 c:=b
 c[1,2,2,1]:="changed"
 ? Len(b[1][2][2][1])
RETURN NIL

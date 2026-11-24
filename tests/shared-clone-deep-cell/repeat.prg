// Own MIT: nested cyclic child clones across return boundaries.
FUNCTION CopyChild(p)
RETURN AClone(p[1,1,1])
FUNCTION Work()
 LOCAL a:=AClone({{{{"word",19.25,{17}}}}}),b,i,n:=0
 a[1,1,1,3]:=a[1,1,1]
 FOR i:=1 TO 117
  b:=AClone(a[1,1,1])
  b[1]:="changed"
  b[2]:=21.5
  n+=Len(b)
  b:=CopyChild(a)
  n+=Len(b)
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

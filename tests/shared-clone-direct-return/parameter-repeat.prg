// Own MIT: cyclic clones returned through nested calls and replaced.
FUNCTION CopyGraph(p)
RETURN AClone(p)
FUNCTION Work()
 LOCAL a:=AClone({"root",19.25}),b:=AClone({"child"}),c,i,n:=0
 AAdd(a,b)
 AAdd(a,b)
 AAdd(b,a)
 FOR i:=1 TO 117
  c:=CopyGraph(a)
  c:=CopyGraph(c)
  c[1]:="changed"
  c[2]:=21.5
  c[3,1]:="leaf"
  IF c[3]==c[4] .AND. c[3,2]==c .AND. !(c==a)
   n++
  ENDIF
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

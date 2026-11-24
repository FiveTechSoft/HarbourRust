// Own MIT: a first argument must remain rooted while the second allocates.
FUNCTION CopyGraph(p)
RETURN AClone(p)
FUNCTION Pair(p,q)
 LOCAL i
 p[1]:="changed"
 p[2]:=21.5
 p[3,1]:="leaf"
 FOR i:=1 TO 17
  AAdd(q,i)
 NEXT
RETURN Len(p)+Len(q)
FUNCTION Work()
 LOCAL a:=AClone({"word",19.25,{"child"}}),i,n:=0
 FOR i:=1 TO 117
  n+=Pair(AClone(a),CopyGraph(a))
  n+=Pair(AClone({"word",19.25,{"child"}}),CopyGraph(a))
 NEXT
RETURN n
FUNCTION Main()
 LOCAL i,n:=0
 FOR i:=1 TO 37
  n+=Work()
 NEXT
 ? n
RETURN NIL

// Own MIT: clone values as direct call arguments own independent graphs.
FUNCTION Touch(p)
 LOCAL n:=p[2,1]
 p[2,1]:=23
RETURN n
FUNCTION Cycle(p)
 ? p[3]==p,p[2,1]
 p[2,1]:=29
RETURN Len(p)
FUNCTION Pair(p,q)
 ? p==q,p[2]==q[2]
 p[2,1]:=31
RETURN q[2,1]
FUNCTION Main()
 LOCAL a:=AClone({"root",{17}})
 ? Touch(AClone(a)),a[2,1]
 ? Touch(AClone({"literal",{19}})),a[2,1]
 ? Pair(AClone(a),AClone(a)),a[2,1]
 AAdd(a,a)
 ? Cycle(AClone(a)),a[2,1],a[3]==a
RETURN NIL

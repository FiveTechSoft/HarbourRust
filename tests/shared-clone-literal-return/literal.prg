// Own MIT: explicit literal AClone returns preserve caller identity.
FUNCTION Make()
RETURN AClone({"root",19.25,SToD("20040229"),{17,NIL,.T.}})
FUNCTION MakeEmpty()
RETURN AClone({})
FUNCTION Main()
 LOCAL a:=Make(),b:=Make(),c:=MakeEmpty(),d:=MakeEmpty()
 ? a==b,a[4]==b[4],a[4,1],b[4,1],Len(c),Len(d),c==d
 b[1]:="changed"
 b[2]:=21.5
 b[4,1]:=23
 b[4,3]:=.F.
 ? a[1],b[1],a[2],b[2],DToS(b[3]),a[4,1],b[4,1],a[4,3],b[4,3]
 AAdd(c,c)
 ? Len(c),Len(d),c[1]==c
RETURN NIL

FUNCTION Main()
 LOCAL b,c,d
 b:=AClone({1,2,"word",{NIL,"nested"},19.25,SToD("20040229")})
 c:=AClone({1,2,"word",{NIL,"nested"},19.25,SToD("20040229")})
 b[1]:=17
 b[3]:="changed"
 b[4,2]:="other"
 ? b[1],c[1],b[3],c[3],b[4,2],c[4,2],b[5],c[5],DToS(b[6])
 d:=AClone({})
 ? Len(d),ValType(d),Len(b)
 AAdd(d,"new")
 ? d[1]
RETURN NIL

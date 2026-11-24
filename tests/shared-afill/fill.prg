FUNCTION Main()
 LOCAL a:=AClone({17,"word",19.25,{"child"}}),b:=a,c
 c:=a[4]
 AFill(a,a[2],0,3)
 ? a[1],a[2],a[3],a[4,1],c[1]
 a[2]:="changed"
 ? b[1],b[2],b[3]
 a[1]:=19.25
 AFill(a,a[1],2,99)
 ? a[1],a[2],a[3],a[4],c[1]
 AFill(a,"no",-1)
 AFill(a,"no",99)
 AFill(a,"no",1,0)
 ? a[1],Len(a)
 AFill(a,NIL)
 ? ValType(a[1]),ValType(a[4])
 a:=AClone({})
 AFill(a,"empty")
 ? Len(a)
RETURN NIL

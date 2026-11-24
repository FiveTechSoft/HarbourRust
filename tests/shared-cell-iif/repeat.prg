FUNCTION Work()
 LOCAL a:=AClone({17,"word",19.25}),i,c
 FOR i:=1 TO 117
  c:=IIF(.F.,Replicate("dead",31),a[2])
  c:=IIF(.T.,Replicate("live",31),a[1])
  c:=IIF(.T.,a[3],Replicate("dead",31))
 NEXT
RETURN c
FUNCTION Main()
 LOCAL i,c
 FOR i:=1 TO 37
  c:=Work()
 NEXT
 ? c
RETURN NIL

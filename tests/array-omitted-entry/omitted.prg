FUNCTION Main()
 LOCAL a:={{,}},b:={NIL},c:=1,i
 ? Len(a),Len(a[1]),a[1,1],a[1,2]
 a[1,2]:="hello"
 b:=a
 FOR i:=1 TO 117
  a[1,1]:="owned"+hb_ntos(i)
 NEXT
 ? b[1,1],b[1,Val(" +2 ")]
 a:={{,,}}
 ? Len(a[1]),a[1,1],a[1,2],a[1,3]
RETURN NIL

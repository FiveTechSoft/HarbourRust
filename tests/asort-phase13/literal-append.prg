FUNCTION Main()
 LOCAL a:={},b:={2,1},i
 ASort(b)
 FOR i:=1 TO 113
  AAdd(a,{"text",1.25,SToD("20260101"),{},NIL})
 NEXT
 ASort(a,NIL,NIL,{|x,y|x[2]<y[2]})
 ? Len(a),a[1][1],a[113][2],a[2][3]
RETURN NIL

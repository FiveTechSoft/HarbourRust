STATIC calls:=0
FUNCTION CompareOrFail(x,y,limit)
 calls++
 IF calls>limit
  Break("expected")
 ENDIF
RETURN x<y
FUNCTION Main()
 LOCAL a:={{"z",4},{"a",1},{"m",3},{"b",2}},i:=0,e,n:=2,caught:=0
 FOR i:=1 TO 137
  calls:=0
  BEGIN SEQUENCE
   ASort(a,NIL,NIL,{|x,y|CompareOrFail(x[2],y[2],n)})
  RECOVER USING e
   caught++
  END SEQUENCE
  ASort(a,NIL,NIL,{|x,y|x[1]<y[1]})
 NEXT
 ? caught,Len(a),a[1][1],a[4][1],a[1][2],a[4][2]
RETURN NIL

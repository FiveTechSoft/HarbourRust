STATIC calls:=0
FUNCTION CompareOrFail(x,y,limit)
 calls++
 IF calls>limit
  Break("expected")
 ENDIF
RETURN x<y
FUNCTION Main()
 LOCAL a:={},i:=0,j:=0,e,n:=3,caught:=0,b:={2,1}
 ASort(b)
 FOR i:=1 TO 151
  a:={"z","a","q","m","b","s","r"}
  calls:=0
  BEGIN SEQUENCE
   ASort(a,NIL,NIL,{|x,y|CompareOrFail(x,y,n)})
  RECOVER USING e
   caught++
  END SEQUENCE
  ASort(a)
 NEXT
 ? caught,a[1],a[7],Len(a)
RETURN NIL

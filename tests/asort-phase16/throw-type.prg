FUNCTION Main()
 LOCAL a:={"z","a","q","m","b","s","r"},i:=0,e,caught:=0,b:={2,1}
 ASort(b)
 FOR i:=1 TO 113
  BEGIN SEQUENCE
   ASort(a,NIL,NIL,{|x,y|x+1<y})
  RECOVER USING e
   caught++
  END SEQUENCE
 NEXT
 ASort(a)
 ? caught,Len(a),a[1],a[7]
RETURN NIL

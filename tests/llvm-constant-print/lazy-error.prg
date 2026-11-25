FUNCTION Main()
LOCAL a:="A",b:="B",v:={1,2},n:=9223372036854775807,i:=0,bad:=0,high:=3
? IIf(.T.,IIf(.T.,a,b),IIf(v[bad]==0,b,a))
? IIf(.F.,IIf(v[high]==0,a,b),IIf(.T.,b,a))
? IIf(.T.,IIf(.T.,a,b),IIf(++n>0,b,a)),n
FOR i:=1 TO 3
 ? IIf(i>0,IIf(i==2,b,a),IIf(v[bad]==0,a,b)),i
NEXT
RETURN NIL

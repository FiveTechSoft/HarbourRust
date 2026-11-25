FUNCTION Main()
LOCAL a:="A",b:="B",z:="",n:=0,i:=0
? IIf(++n==1,IIf(++n==2,a,b),IIf(++n==99,b,a)),n
? IIf(++n==99,IIf(++n==99,a,b),IIf(++n==4,b+"x",a+"y")),n
?? IIf(n==4,IIf(.T.,z+" tail  ",a),b)
OutStd(IIf(.F.,a,IIf(.T.,z+"RAW",b)))
? IIf(.T.,IIf(.F.,a,z+Chr(0)+"C"),b),n
FOR i:=1 TO 3
 ? IIf(i==2,IIf(++n>0,a+"x",b),IIf(++n>0,b+"y",a)),n
NEXT
? IIf(.T.,IIf(.T.,z,z+a),b)
RETURN NIL

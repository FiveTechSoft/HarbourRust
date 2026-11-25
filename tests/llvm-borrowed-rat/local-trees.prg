FUNCTION Main()
LOCAL a:="ab",b:="c",empty:="",n:=0
? Rat(a+b,"x"+a+b+"y"+a+b),Rat(a+b,a+b),Rat(a+b,b+a)
? Rat(a+Chr(0),"x"+a+Chr(0)+a+Chr(0)),Rat(Chr(0)+a,a+Chr(0))
? Rat(empty+a,a+empty),Rat(empty+a,empty),Rat(empty,a+empty)
? Rat("中"+a,"é"+"中"+a),Rat(a+"x",a+"y")
FOR n:=1 TO 2
 ? Rat(a+b,"x"+a+b)+n,Rat(a+b,"x"+a+b)==2
NEXT
RETURN NIL

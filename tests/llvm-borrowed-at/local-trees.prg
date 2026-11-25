FUNCTION Main()
LOCAL a:="ab",b:="c",empty:="",n:=0
? At(a+b,"x"+a+b+"y"+a+b),At(a+b,a+b),At(a+b,b+a)
? At(a+Chr(0),"x"+a+Chr(0)+a+Chr(0)),At(Chr(0)+a,a+Chr(0))
? At(empty+a,a+empty),At(empty+a,empty),At(empty,a+empty)
? At("中"+a,"é"+"中"+a),At(a+"x",a+"y")
FOR n:=1 TO 2
 ? At(a+b,"x"+a+b)+n,At(a+b,"x"+a+b)==2
NEXT
RETURN NIL

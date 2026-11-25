FUNCTION Main()
LOCAL a:="ab",b:="",s:=" ",n:=0
? a+b,b+b,(a+Chr(0))+"c",b+"é中"
? "["+a+"]",s+s
?? s+a+s
?? b+b
? b+s
OutStd(b+a,s+a+s)
? "done"
FOR n:=1 TO 2
 ? a+"x",b+a,n
NEXT
RETURN NIL

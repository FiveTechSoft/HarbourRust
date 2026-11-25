FUNCTION Main()
LOCAL a:=" ",b:="",n:=0,i:=0,v:={1,2},bad:=0
? Empty(IIf(.T.,a+b,b+"x")),Empty(IIf(.F.,a+b,b+Chr(0)))
? Empty(IIf(++n==1,IIf(++n==2,a+Chr(9),b+"x"),IIf(++n==99,b+"x",a+b))),n
? Empty(IIf(.T.,a+b,IIf(v[bad]==0,a+b,b+"x"))),n
FOR i:=1 TO 3
 ? Empty(IIf(i==2,IIf(++n>0,a+b,b+"x"),IIf(++n>0,b+"x",a+b))),n
NEXT
IF Empty(IIf(n>0,a+b,b+"x"))
 n++
ENDIF
? n,IIf(Empty(IIf(.F.,a+b,b+"é")),17,99)
RETURN NIL

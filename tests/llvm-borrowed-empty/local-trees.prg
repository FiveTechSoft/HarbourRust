FUNCTION Main()
LOCAL a:=" ",b:="",c:=Chr(9),n:=0
? Empty(a+b),Empty(b+b),Empty(a+c),Empty(b+Chr(13)+Chr(10))
? Empty(a+Chr(0)),Empty(b+"é"),Empty(b+Chr(11)),Empty(b+"x")
IF Empty(a+c).AND.!Empty(a+Chr(0))
 n++
ENDIF
? n,IIf(Empty(a+b),17,99),Empty(Empty(b+"x"))
RETURN NIL

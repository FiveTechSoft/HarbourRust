FUNCTION Main()
LOCAL a:="ab",b:="c",empty:="",n:=0
? (a+b)=="abc",(a+b)==(a+b),(a+b)==(b+a)
? (a+Chr(0))==(a+Chr(0)),(a+Chr(0))==a
? (empty+a)==a,(empty+a)==(a+empty),(a+" ")==a
? (a+"é")==("ab"+"é"),(a+"é")==("ab"+"e")
IF ((a+b)==(a+"c")).AND. !((a+b)==(b+a))
 n++
ENDIF
? n,IIf((a+b)==(a+"c"),17,99),Empty((a+b)==(b+a))
RETURN NIL

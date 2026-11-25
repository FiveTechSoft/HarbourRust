FUNCTION Main()
LOCAL a:="yes",b:=(a=="yes"),n:=0
? b,!(a=="no"),(a=="yes").AND.(a=="yes")
IF a==("y"+"es")
 n++
ENDIF
? n,IIf(a=="yes",17,99),Empty(a=="no")
RETURN NIL

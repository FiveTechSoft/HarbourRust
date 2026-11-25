FUNCTION Main()
LOCAL s:="abc"
? "abc"==IIf(.T.,s,Upper("abc"))
RETURN NIL

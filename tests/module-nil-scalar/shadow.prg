STATIC n
FUNCTION Main()
n := 7
? PrivateN(), ReadN(), ParamN(12), ReadN()
RETURN NIL
FUNCTION PrivateN()
LOCAL n := 99
RETURN n
FUNCTION ParamN(n)
RETURN n
FUNCTION ReadN()
RETURN n

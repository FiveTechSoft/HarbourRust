STATIC a
FUNCTION Main()
a:=1
? Eval({||Value()})
RETURN NIL
FUNCTION Value()
RETURN a

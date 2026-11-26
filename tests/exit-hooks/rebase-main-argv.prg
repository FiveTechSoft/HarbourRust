PROCEDURE Main(a,b)
? "main",PCount(),a,b
CountCalls()
RETURN
FUNCTION CountCalls()
? "caller",Counted(),Counted(NIL),Counted(1,2)
RETURN NIL
FUNCTION Counted(a,b)
RETURN PCount()
INIT PROCEDURE BeginHook()
? "init",PCount()
RETURN
EXIT PROCEDURE EndHook()
? "exit",PCount()
? "exit-call",Counted(7)
RETURN

INIT PROCEDURE Hook()
? ErrorLevel(9)
QUIT
RETURN
PROCEDURE Main()
? "bad"
RETURN
EXIT PROCEDURE LastHook()
? "exit",ErrorLevel()
RETURN

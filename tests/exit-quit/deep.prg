PROCEDURE Main()
? "main"

RETURN
EXIT PROCEDURE FirstHook()
? "first"
Deeper()
RETURN
EXIT PROCEDURE SecondHook()
? "second"
RETURN
PROCEDURE Deeper()
? "deep"
QUIT
RETURN

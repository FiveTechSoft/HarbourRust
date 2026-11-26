INIT PROCEDURE FirstInit()
? "init1"
RETURN
INIT PROCEDURE SecondInit()
? "init2"
StopNow()
RETURN
PROCEDURE Main()
? "main"
RETURN
EXIT PROCEDURE FirstExit()
? "exit1"
RETURN
EXIT PROCEDURE SecondExit()
? "exit2"
RETURN
PROCEDURE StopNow()
? "deep"
QUIT
RETURN

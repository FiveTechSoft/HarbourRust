STATIC n:=10
PROCEDURE Main()
? "main",n
RETURN
INIT PROCEDURE StartHook()
? "init",n
RETURN
EXIT PROCEDURE FirstHook()
STATIC s:="first"
n:=n+1
? s,n
RETURN
EXIT PROCEDURE SecondHook()
STATIC s:="second"
n:=n+1
? s,n
RETURN

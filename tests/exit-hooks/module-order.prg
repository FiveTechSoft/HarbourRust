STATIC g:="base"
PROCEDURE Main()
g:=g+"main"
RETURN
INIT PROCEDURE StartHook()
g:=g+"init"
RETURN
EXIT PROCEDURE FirstHook()
g:=g+"first"
? g
RETURN
EXIT PROCEDURE LastHook()
g:=g+"last"
? g
RETURN

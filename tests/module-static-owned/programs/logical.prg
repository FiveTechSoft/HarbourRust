STATIC flag := .T.
PROCEDURE Main()
? flag,Flip(),flag,Flip(),flag
RETURN
FUNCTION Flip()
flag := !flag
RETURN flag

STATIC flag := .T.
PROCEDURE Main()
Flip(@flag)
RETURN
FUNCTION Flip(value)
value := !value
RETURN NIL

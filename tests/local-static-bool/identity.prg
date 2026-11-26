STATIC n:=.T.
PROCEDURE Main()
? F(),G(),F(),G(),n
RETURN
FUNCTION F()
STATIC n:=.T.
n:=!n
RETURN n
FUNCTION G()
STATIC n:=.F.
n:=!n
RETURN n

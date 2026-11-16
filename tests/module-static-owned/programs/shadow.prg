STATIC text := "module",flag := .T.
PROCEDURE Main()
LOCAL result := Shadow("param")
? result,text,flag
RETURN
FUNCTION Shadow(text)
LOCAL flag := .F.
? flag
RETURN text

STATIC text := "initial",flag := .F.
INIT PROCEDURE First()
text := text+"!"
flag := .T.
RETURN
PROCEDURE Main()
? text,flag
RETURN

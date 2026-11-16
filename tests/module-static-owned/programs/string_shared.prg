STATIC text := "initial"
PROCEDURE Main()
? text
? ReadText()
Change()
? text
? ReadText()
RETURN
FUNCTION ReadText()
RETURN text
FUNCTION Change()
text := "changed"
RETURN NIL

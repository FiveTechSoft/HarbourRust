STATIC text := "one"
PROCEDURE Main()
LOCAL saved := GetText()
Change()
? saved,text
RETURN
FUNCTION GetText()
RETURN text
FUNCTION Change()
text := "two"
RETURN NIL

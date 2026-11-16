STATIC text := "old"
PROCEDURE Main()
LOCAL r := Change()
? text, r
RETURN
FUNCTION Change()
text := "new"
RETURN 1

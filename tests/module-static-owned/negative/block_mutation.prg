STATIC text := "old"
PROCEDURE Main()
? text, {|| Change()}
RETURN
FUNCTION Change()
text := "new"
RETURN 1

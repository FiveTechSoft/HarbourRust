STATIC text := "old"
PROCEDURE Main()
? text, {"k"=>Change()}
RETURN
FUNCTION Change()
text := "new"
RETURN 1

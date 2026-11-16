STATIC text := "old"
PROCEDURE Main()
? Left(text,Change())
RETURN
FUNCTION Change()
text := "new"
RETURN 1

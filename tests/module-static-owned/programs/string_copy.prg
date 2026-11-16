STATIC text := "abc"
PROCEDURE Main()
LOCAL first := text
LOCAL second := ""
second := text
text := "new"
? first,second,text
RETURN

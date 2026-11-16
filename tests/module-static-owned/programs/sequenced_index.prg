STATIC text := "old"
PROCEDURE Main()
LOCAL a := {{1}}
LOCAL i
i := Change()
? text, a[i,1]
RETURN
FUNCTION Change()
text := "new"
RETURN 1

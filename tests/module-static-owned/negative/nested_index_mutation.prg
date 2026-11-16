STATIC text := "old"
PROCEDURE Main()
LOCAL a := {{1}}
? text, a[a[Change(),1],1]
RETURN
FUNCTION Change()
text := "new"
RETURN 1

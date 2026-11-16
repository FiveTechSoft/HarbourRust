STATIC text := "old"
PROCEDURE Main()
LOCAL a := {{1}}
? Show(text,a[Change(),1])
RETURN
FUNCTION Show(t,x)
RETURN t
FUNCTION Change()
text := "new"
RETURN 1

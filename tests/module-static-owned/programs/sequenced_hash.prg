STATIC text := "old"
PROCEDURE Main()
LOCAL v := Change()
LOCAL h := {"k"=>v}
? text, h["k"]
RETURN
FUNCTION Change()
text := "new"
RETURN 1

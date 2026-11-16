STATIC text := "old"
PROCEDURE Main()
LOCAL b := {|| Change()}
LOCAL r := Eval(b)
? text, r
RETURN
FUNCTION Change()
text := "new"
RETURN 1

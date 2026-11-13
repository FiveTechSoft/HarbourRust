PROCEDURE Main()
LOCAL s := "A" + Chr(0) + "B"
? s
?? s
QOut(s)
QQOut(s)
OutStd(s)
OutErr(s)
? "x" + Chr(0) + "z  "
OutStd(Replicate("x",255) + Chr(0) + Replicate("y",256) + Chr(0) + "z")
RETURN

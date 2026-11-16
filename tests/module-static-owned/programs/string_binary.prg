STATIC text := "a"
PROCEDURE Main()
LOCAL zero := Chr(0)
text := text+zero+"b"
? Len(text),Asc(SubStr(text,2,1)),Asc(Right(text,1))
RETURN

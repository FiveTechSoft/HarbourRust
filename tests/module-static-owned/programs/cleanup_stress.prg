STATIC text := "seed",other := "other"
PROCEDURE Main()
LOCAL i
FOR i := 1 TO 300
Exercise()
NEXT
? text,other
RETURN
FUNCTION Exercise()
LOCAL saved := text
text := "replacement"
other := text
text := saved
RETURN NIL

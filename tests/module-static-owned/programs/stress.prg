STATIC text := "seed"
PROCEDURE Main()
LOCAL i
FOR i := 1 TO 100
Work()
NEXT
? text
RETURN
FUNCTION Work()
LOCAL saved := text
text := "seed"
text := text+"!"
text := saved
RETURN NIL

PROCEDURE Main()
LOCAL s := "ab"
LOCAL x
FOR EACH x IN s
? (s := "new", x)
NEXT
RETURN

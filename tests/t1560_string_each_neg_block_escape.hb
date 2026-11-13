PROCEDURE Main()
LOCAL s := "ab"
LOCAL x
FOR EACH x IN s
LOCAL b := {|| Asc(x)}
NEXT
RETURN

PROCEDURE Main()
LOCAL i
FOR i := 1 TO 4
IF CurDir("C") <> CurDir()
? "wrong"
ENDIF
NEXT
? "done"
RETURN

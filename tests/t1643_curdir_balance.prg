PROCEDURE Main()
LOCAL i
LOCAL before := HB_MEMCHECK()
FOR i := 1 TO 10
IF Len(CurDir()) < 0
? "wrong"
ENDIF
NEXT
? HB_MEMCHECK() == before
RETURN

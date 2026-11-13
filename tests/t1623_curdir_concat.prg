PROCEDURE Main()
LOCAL s := "[" + CurDir() + "]"
? Len(s) == Len(CurDir())+2
RETURN

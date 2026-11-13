PROCEDURE Main()
LOCAL s := Place()
? s == CurDir()
RETURN
FUNCTION Place()
RETURN CurDir()

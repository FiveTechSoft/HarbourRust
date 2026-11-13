PROCEDURE Main()
LOCAL s := IIF(.T., CurDir(), "not chosen")
? s == CurDir()
RETURN

INIT PROCEDURE First()
LOCAL s := Replicate("x", 20)
LOCAL a := {1,2,3}
? Len(s), a[2]
RETURN
INIT PROCEDURE Last()
LOCAL s := "owned" + " string"
? Len(s)
RETURN
PROCEDURE Main()
? HB_MEMCHECK() == 0
RETURN

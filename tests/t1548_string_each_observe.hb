PROCEDURE Main()
LOCAL s := "A" + Chr(0) + "Z"
LOCAL x := 987
FOR EACH x IN s
 ? Asc(x), Len(x), ValType(x)
NEXT
? x, Len(s)
s := ""
FOR EACH x IN s
 ? "bad empty"
NEXT
? x, Len(s)
s := "abc"
FOR EACH x IN s
 IF Asc(x) == 98
  LOOP
 ENDIF
 ? x
NEXT
? x
FOR EACH x IN s
 ? Asc(x)
 EXIT
NEXT
? x, s
RETURN

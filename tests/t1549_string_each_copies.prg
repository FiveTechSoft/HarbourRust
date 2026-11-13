PROCEDURE Main()
LOCAL s := "A" + Chr(0) + "Z"
Scan(s)
? s, Len(s)
Scan(s)
Scan("lit")
Scan(Chr(65) + "B")
? s, Len(s)
RETURN
PROCEDURE Scan(s)
LOCAL x
FOR EACH x IN s
 ? Asc(x)
NEXT
RETURN

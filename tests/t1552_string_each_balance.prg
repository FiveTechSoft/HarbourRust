PROCEDURE Main()
LOCAL s := "A" + Chr(0) + "B"
LOCAL before := HB_MEMCHECK()
Scan(s)
Scan(s)
Scan(Chr(65) + "Z")
? before == HB_MEMCHECK(), Len(s)
RETURN
PROCEDURE Scan(s)
LOCAL x
FOR EACH x IN s
 IF Asc(x) == 65
  LOOP
 ENDIF
NEXT
RETURN

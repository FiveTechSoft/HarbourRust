STATIC a := {3,1,4,1,5}
PROCEDURE Main()
LOCAL t := 0
LOCAL i
FOR i := 1 TO len(a)
t += a[i]
NEXT
? t
? a[1]*a[5]
RETURN

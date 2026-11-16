STATIC a := {5,10,15,20}
PROCEDURE Main()
LOCAL i := 2
? a[i], a[i+1], a[a[1] - 4], a[len(a)]
a[a[1] - 4] := 99
? a[1]
RETURN

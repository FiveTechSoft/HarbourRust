STATIC a := {1,2,3}
PROCEDURE Main()
? Sum3()
Bump()
? Sum3()
Bump()
? Sum3()
RETURN
FUNCTION Sum3()
RETURN a[1]+a[2]+a[3]
PROCEDURE Bump()
a[1] := a[1]+10
a[2] := a[2]+10
a[3] := a[3]+10
RETURN

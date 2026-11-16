STATIC a := {0,0}
PROCEDURE Main()
Writer()
? Reader()
Writer()
? Reader()
RETURN
PROCEDURE Writer()
a[1] := a[1]+1
a[2] := a[2]+100
RETURN
FUNCTION Reader()
RETURN a[1]*1000+a[2]

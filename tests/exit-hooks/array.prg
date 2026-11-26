STATIC a:={1,2,3}
PROCEDURE Main()
a[2]:=9
? "main"
RETURN
EXIT PROCEDURE FirstHook()
AAdd(a,4)
? a[2],a[4],Len(a)
RETURN

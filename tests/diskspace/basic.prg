PROCEDURE Main()
LOCAL c:="/tmp",n
? hb_DiskSpace(c,0),hb_DiskSpace(c,1),hb_DiskSpace(c,2),hb_DiskSpace(c,3)
n:=hb_DiskSpace(c,1)
? ValType(n),Str(n),Str(n,30,4),hb_ntos(n)
? Transform(hb_DiskSpace(c,0),"999,999,999,999")
RETURN

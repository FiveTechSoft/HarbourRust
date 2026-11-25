FUNCTION Work()
LOCAL i,c:="/dev/shm",n:=hb_DiskSpace(c,0)
FOR i:=1 TO 1000
 n:=hb_DiskSpace(c,0)
NEXT
RETURN n
PROCEDURE Main()
LOCAL b
Work()
b:=hb_memcheck()
Work()
OutStd(hb_memcheck()-b,Chr(10))
RETURN

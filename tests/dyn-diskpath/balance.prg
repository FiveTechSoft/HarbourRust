FUNCTION Work()
LOCAL i,c,n
c:="/dev/shm"
FOR i:=1 TO 1000
 n:=hb_DiskSpace(c,0)
 c:=Lower("/DEV/SHM")
NEXT
RETURN c
PROCEDURE Main()
LOCAL b,c:=Work()
b:=hb_memcheck()
c:=Work()
OutStd(hb_memcheck()-b,Chr(10))
RETURN

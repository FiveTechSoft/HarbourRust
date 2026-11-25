FUNCTION Work()
LOCAL i,c:=hb_DirBase()
FOR i:=1 TO 1000
 c:=hb_DirBase()
NEXT
RETURN c
PROCEDURE Main()
LOCAL b,c:=Work()
b:=hb_memcheck()
c:=Work()
OutStd(hb_memcheck()-b,Chr(10))
RETURN

FUNCTION Main()
LOCAL i:=0,s:=1
FOR i:=1 TO 2 STEP s
 ? i
NEXT
RETURN NIL
FUNCTION ignored()
RETURN hb_threadSelf()

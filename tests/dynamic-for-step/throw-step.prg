PROCEDURE Main()
 LOCAL i:=0,e
 BEGIN SEQUENCE
 FOR i:=1 TO 3 STEP ThrowStep()
 ? "body",i
 NEXT
 RECOVER USING e
 ? "caught",e,i
 END SEQUENCE
RETURN
FUNCTION ThrowStep()
 ? "step"
 BREAK 17
RETURN 1

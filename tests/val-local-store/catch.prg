PROCEDURE Main()
LOCAL n := 3
n := Val("1.25")
BEGIN SEQUENCE WITH {|b|Break(b)}
 n := Val(NIL)
RECOVER
 ? "caught",n
END SEQUENCE
? n
RETURN

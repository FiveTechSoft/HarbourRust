FUNCTION Main()
LOCAL n:=0
? NIL,++n,NIL,++n,NIL
?? NIL,NIL
OutStd("|",NIL,"|",++n)
? NIL,Observe(),NIL,n
? NIL,"  ",NIL,""
RETURN NIL
FUNCTION Observe()
? "inside"
RETURN 29

FUNCTION Main()
LOCAL a:=0
? "before",Bump(++a),a,"  "
OutStd("raw",Bump(++a),a)
?? "tail"
? "last",a
RETURN NIL
FUNCTION Bump(n)
n++
?? "[",n,"]"
RETURN n

FUNCTION Main()
LOCAL a:="xyz",i
FOR i:=1 TO 100
 ? Replicate(a,i)+Replicate("!",i),(""+a)+(a+""),Upper(a)+Lower(a)
NEXT
RETURN NIL

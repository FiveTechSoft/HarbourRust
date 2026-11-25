FUNCTION Main()
LOCAL a:="0123456789",b:="A"+Chr(8)+"B",c:="A"+Chr(13)+"B",d:="A"+Chr(7)+"B",n:=0,z:=Chr(0),t:=Chr(9),r:=Chr(13),l:=Chr(10)
? a,a,a,a,a,a,a,a,a
? b,c,d
FOR n:=1 TO 27
 ? n,"line"
NEXT
?? " tail  "
?? ""
OutStd("raw",z,t,r,l)
?? "END"
RETURN NIL

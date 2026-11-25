FUNCTION Main()
LOCAL a:="abc",b:="ab"
? a==b,a=="abc",""=="",("A"+Chr(0))=="A"
? "a"=="A","x "=="x","x"=="x ",""==" "
? "é"=="é","é"=="e",("a"+Chr(0)+"b")==("a"+Chr(0)+"b")
? (Chr(0)+"x")==Chr(0),(Chr(0)+"x")==(""+Chr(0)+"y")
RETURN NIL

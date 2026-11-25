FUNCTION Main()
LOCAL a:="A",z:=""
? z+Chr(0)+a,z+Chr(1)+a,z+Chr(9)+a,z+Chr(10)+a
? z+Chr(13)+a,z+Chr(31)+a,z+Chr(127)+a
?? z+"tail  "
?? " "+a+" "
? z+""
RETURN NIL

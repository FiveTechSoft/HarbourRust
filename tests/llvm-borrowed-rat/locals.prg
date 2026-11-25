FUNCTION Main()
LOCAL a:="ABA",b:="ABABA",c:="á中🙂",n:=1
? Rat(a,b),Rat("BA",b),Rat("ABABA",a),Rat("",b),Rat(a,"")
? Rat("中",c),Rat("🙂",c),Rat("á",c),Rat("x",c)
FOR n:=1 TO 3
 ? Rat(a,b)+n,Rat(a,b)==1
NEXT
RETURN NIL

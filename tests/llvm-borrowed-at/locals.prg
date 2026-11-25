FUNCTION Main()
LOCAL a:="ABA",b:="ABABA",c:="á中🙂",n:=1
? At(a,b),At("BA",b),At("ABABA",a),At("",b),At(a,"")
? At("中",c),At("🙂",c),At("á",c),At("x",c)
FOR n:=1 TO 3
 ? At(a,b)+n,At(a,b)==1
NEXT
RETURN NIL

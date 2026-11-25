FUNCTION Main()
LOCAL a:="",b:=" "+Chr(9)+Chr(10)+Chr(13),c:="á中🙂",d:=" "+Chr(0)+" "
? Empty(a),Empty(b),Empty(c),Empty(d)
? Empty(""),Empty(" "+Chr(9)),Empty(" x "),Len(b)
IF Empty(b)
 ? "blank"
ENDIF
RETURN NIL

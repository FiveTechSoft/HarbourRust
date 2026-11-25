FUNCTION Main()
LOCAL a:="ab",b:="c"
? ("x"+a)$(b+a),("x"+a)$("x"+a)
? (a+"x")$b,a$(b+"x"),(a+"x")$(b+"y")
IF ("x"+a)$(b+a)
? "BAD"
ELSE
? "FALSE"
ENDIF
RETURN NIL

FUNCTION Main()
LOCAL a:="ab",s:="cabcd",b:=(a$s),n:=0
? b,!("z"$s),(a$s).AND.("c"$s)
IF a$s
 n++
ENDIF
? n,IIf(a$s,17,99),Empty("z"$s)
RETURN NIL

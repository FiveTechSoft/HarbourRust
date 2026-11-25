FUNCTION bump()
?? "RHS-EFFECT"
RETURN 5
#ifdef ORACLE_ERROR_HANDLER
FUNCTION handler(e)
HB_SYMBOL_UNUSED(e)
OutErr("BOUND")
ErrorLevel(7)
QUIT
RETURN NIL
#endif
FUNCTION Main()
LOCAL a:={1,2},i:=0
#ifdef ORACLE_ERROR_HANDLER
ErrorBlock({|e| handler(e)})
#endif
? (a[i]+=bump())
RETURN NIL

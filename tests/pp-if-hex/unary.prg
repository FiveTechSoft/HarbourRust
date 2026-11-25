FUNCTION Main()
#if -16 == (0-16) .AND. +16 == 16 .AND. -(2+3) == (0-5)
? "unary"
#else
? "wrong"
#endif
RETURN NIL

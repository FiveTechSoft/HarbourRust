#define defined 0
#define X 7
FUNCTION Main()
#if defined(X)
? "yes"
#else
? "no"
#endif
RETURN NIL

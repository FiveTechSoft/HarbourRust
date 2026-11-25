#define X 7
FUNCTION Main()
#if .not.defined(XYZ)
? "yes"
#else
? "no"
#endif
RETURN NIL

#define A B
FUNCTION Main()
#if defined(A) .AND. !defined(B)
? "yes"
#else
? "no"
#endif
RETURN NIL

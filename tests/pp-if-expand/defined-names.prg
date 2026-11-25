#define A B
#define B 7
FUNCTION Main()
#if defined(A) .AND. defined(B) .AND. !defined(C)
? "names"
#endif
RETURN NIL

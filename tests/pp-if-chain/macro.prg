#define CHAIN(a,b,c) a<b<c
FUNCTION Main()
#if CHAIN(3,2,1)
? "CHAIN"
#endif
#if 0
? "BAD"
#elif 2==2>0
? "ELIF"
#endif
RETURN NIL

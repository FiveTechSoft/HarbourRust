#define NE <>
#define ALT(a,b) a # b
#define ONE 1
FUNCTION Main()
#if ONE NE 2
? "NE"
#endif
#if ALT(1,2)
? "ALT"
#endif
#if 0
? "BAD"
#elif 2#3
? "ELIF"
#endif
RETURN NIL

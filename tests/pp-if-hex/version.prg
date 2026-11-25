#define HEX 0xAB
FUNCTION Main()
#if __HARBOUR__ > 0x010100
? "yes"
#else
? "no"
#endif
RETURN NIL

FUNCTION Main()
#if (8<<-1)==0 .AND. (8>>-1)==0 .AND. (-8>>65)==-4
? "masked"
#endif
#if (1<<0x8000000000000000)==1 .AND. (1<<0xffffffffffffffff)==0x8000000000000000
? "extreme"
#endif
RETURN NIL

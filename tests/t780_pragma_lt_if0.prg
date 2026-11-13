procedure main()
#if __pragma( WARNINGLEVEL ) < 3
   ? "lt3"
#else
   ? "ge3"
#endif
#if 0
   ? "zero-active"
#else
   ? "zero-inactive"
#endif
return

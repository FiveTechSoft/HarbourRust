procedure main()
#if __pragma( WARNINGLEVEL ) == 0
   ? "w0"
#elif __pragma( WARNINGLEVEL ) == 1
   ? "w1"
#elif __pragma( WARNINGLEVEL ) == 2
   ? "w2"
#else
   ? "w3plus"
#endif
return

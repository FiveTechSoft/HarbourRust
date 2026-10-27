#warning silent
#if __pragma(WARNINGLEVEL) == 0
procedure main()
? "w0"
return
#else
#error wrong level
#endif

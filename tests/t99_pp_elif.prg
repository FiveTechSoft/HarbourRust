// #elif chain (probe b25)
#define N 2
function main()
#if N == 1
? "one"
#elif N == 2
? "two"
#else
? "other"
#endif
return nil

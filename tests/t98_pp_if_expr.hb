// Harbour #if expressions: relational, .AND., unary !, arithmetic (probe b24)
#define N 5
function main()
#if N > 3
? "gt"
#endif
#if N <= 5
? "le"
#endif
#if N > 3 .AND. N < 10
? "and"
#endif
#if !(N == 4)
? "not"
#endif
#if N + 1 == 6
? "arith"
#endif
return nil

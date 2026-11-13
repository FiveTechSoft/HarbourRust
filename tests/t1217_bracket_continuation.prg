#define TEXT [a;b]
#define LITERAL(x) [x]
procedure main()
? TEXT
? LITERAL(7)
? [a;] + ; // join outside bracket
 [b]
return

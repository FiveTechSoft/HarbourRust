#define STORE(x,y) local a := x ; local b := y
procedure main()
STORE({1,2},{3,4,5})
? Len(a)+Len(b)
return

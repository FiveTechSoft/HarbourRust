#define SHOW ? "quoted;macro"; ? "second"
procedure main()
local n := 1; n++; ? n, 'a;b', "x;/*notcomment*/"
SHOW
? "end"; ? "next" // two statements before a comment
return

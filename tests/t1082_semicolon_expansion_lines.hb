#define TWICE ? "macro1"; ? "macro2"
#command SHOW <x> => ? <x>; ? "end"
procedure main(); local n := 0
TWICE
SHOW "command"
? ProcLine(); ? ProcLine()
? 1 + ; // join
2; ? ProcLine()
return

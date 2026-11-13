#define SHOW ? ProcLine(); ? ProcLine()
function other()
return ProcLine()
function main()
local i := 0
SHOW
for i := 1 to 2
? ProcLine(), other()
next
? 1 + ; // continuation
2; ? ProcLine()
return

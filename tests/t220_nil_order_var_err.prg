// Ordering a NIL held in a variable: Harbour raises a type error whose
// interactive dialog cannot be probed headless; the PoC prints and exits
// 1 (registered failure mode, same error condition). A NIL LITERAL in an
// ordering comparison stays a compile error (t212).
function main()
local x := NIL
if x < 1
   ? "BAD"
endif
? "BAD"
return nil

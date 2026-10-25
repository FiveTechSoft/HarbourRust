// NIL through a parameter and back (probe n1c): pinned i64 by arithmetic,
// the sentinel passes in and out untouched; `p + 0` keeps it (prints NIL).
function f(p)
   ? p + 0
return p
function main()
local r := f(NIL)
? r
return nil

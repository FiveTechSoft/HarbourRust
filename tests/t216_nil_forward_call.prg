// Forward call (probe n3): a tagged array element passes into a call,
// prints and compares inside, and returns untouched.
function show(p)
   ? p
   if p = NIL
      ? "nil-in"
   else
      ? "num-in"
   endif
return p
function main()
local a := {}
AAdd(a, NIL)
AAdd(a, 4)
? show(a[1])
? show(a[2])
return nil

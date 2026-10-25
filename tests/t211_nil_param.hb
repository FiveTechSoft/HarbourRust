// NIL through a parameter and back (probe n1c): the tagged value passes
// in and out untouched and prints as NIL on both sides. (The retired
// sentinel version also did `p + 0` here: arithmetic on NIL is a Harbour
// type error, covered by t218 - not a pass-through case.)
function f(p)
   if p = NIL
      ? "is-nil"
   endif
   ? p
return p
function main()
local r := f(NIL)
? r
return nil

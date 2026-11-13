// NIL then integer: reassignment flips the tag in place (probe n2); a
// value read out of an array stays tagged through the same flips.
function main()
local a := {}
local y := NIL
local b := NIL
? y
y := 5
? y
AAdd(a, NIL)
b := a[1]
? b
b := 3
? b
if b = 3
   ? "ok1"
else
   ? "BAD1"
endif
return nil

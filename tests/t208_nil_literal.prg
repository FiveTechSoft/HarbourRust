// NIL literal: the tagged i64 sentinel (probe n1). Prints "NIL"; stored in
// a dynamic array it survives AAdd, read-back and overwrite with a value.
function main()
local x := NIL
local a := {}
? x
AAdd(a, NIL)
? a[1]
AAdd(a, 5)
? a[2]
a[2] := NIL
? a[2]
return nil

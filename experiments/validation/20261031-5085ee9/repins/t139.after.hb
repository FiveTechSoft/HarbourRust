// neg: a mixed scalar literal is supported (piece 1a), but mixing in a
// nested array is not - the nested form keeps the named rejection.
function main()
local a := {1, "dos", {3}}
? a[1]
return nil

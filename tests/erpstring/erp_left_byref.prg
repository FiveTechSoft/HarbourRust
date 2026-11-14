// Left(s, n): the source argument value is retained before the count
// argument evaluates, so a by-reference reassignment of the source owner
// inside the count call cannot corrupt the slice (Harbour semantics).
function clobber(x)
   x := "ZZZZZZZZZZ"
return 3

function main()
   local s := "abcdef"
   ? left(s, clobber(@s))
   ? s
return nil

// Right(s, n): same retained-source contract as Left (the pre-fix codegen
// dereferenced the freed source buffer here).
function clobber(x)
   x := "ZZZZZZZZZZ"
return 3

function main()
   local r := "abcdef"
   ? right(r, clobber(@r))
   ? r
return nil

// At(search, text): Harbour evaluates the arguments left to right, so the
// search runs first and the text sees any by-reference reassignment the
// search evaluation performed.
function clob(s)
   s := "QQQQQQQQQQ"
   return "bc"

function main()
   local t := "abcabc"
   local u := "abcabc"
   ? at(clob(@t), t)
   ? t
   ? at("bc", u)
   ? at("zz", u)
   ? u
return nil

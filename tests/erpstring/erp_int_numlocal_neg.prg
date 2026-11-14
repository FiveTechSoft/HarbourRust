// A mixed numeric LOCAL keeps its named ABI rejection through Int, like
// through every builtin but Round (pre-existing named limit).
function main()
   local x := 5
   x := 2.5
   ? int(x)
return nil

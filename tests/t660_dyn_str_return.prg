// Dyn string returned from a function: the caller receives its own clone
// (owned temp); stored into a Dyn slot it moves in; printed directly it is
// freed right after printing.
function mkstr()
   local r
   r := "made"
   return r

function main()
   local x
   x := mkstr()
   ? x
   ? mkstr()
   x := NIL
   ? hb_memcheck()
   return

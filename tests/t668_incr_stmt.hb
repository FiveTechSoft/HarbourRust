// Statement ++/-- both affixes (oracle hk246): ++x, x++, --x, x-- on an
// integer local desugar to x := x +/- 1.
function main()
   local x := 0
   ++x
   ? x
   x++
   ? x
   --x
   ? x
   x--
   ? x
   return

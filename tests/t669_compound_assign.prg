// Compound assignment (oracle hk246): +=, -=, *= on an integer local
// desugar to x := x op e. (n /= 2 stays rejected: Harbour yields 24.00.)
function main()
   local n := 10
   n += 5
   ? n
   n -= 3
   ? n
   n *= 4
   ? n
   return

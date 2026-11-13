// `a[i] /= e` is parked: Harbour `/` always yields decimals (0.80
// for 4/5) and the integer array cell cannot hold them until the
// numeric-cell decision (proposal recorded, not approved).
function main()
   local a := { 1, 2, 3 }
   ? a[ 2 ] /= 5
return nil

// Indexed compound assignment, statement form (arrayidx family):
// `a[i] op= e` for +, -, * on integer cells, with the resulting
// value discarded, like a bare call statement (hk216).
function main()
   local a := { 1, 2, 3, 4 }
   a[ 1 ] += 10
   a[ 2 ] -= 10
   a[ 3 ] *= 10
   ? a[ 1 ], a[ 2 ], a[ 3 ], a[ 4 ]
return nil

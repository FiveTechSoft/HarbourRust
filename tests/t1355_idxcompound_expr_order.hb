// Order oracle for `a[i] op= e` used as an expression (arrayidx
// contract): the index expression evaluates ONCE, FIRST; the rhs
// evaluates once, second; the store targets the cell the FIRST
// index evaluation named, even when the rhs mutates the index.
function bump( x )
   x := x + 1
   return 5
function main()
   local a := { 10, 20, 30, 40 }
   local index := 0
   ? a[ ++index ] += bump( @index )
   ? index
   ? a[ 1 ], a[ 2 ], a[ 3 ], a[ 4 ]
return nil

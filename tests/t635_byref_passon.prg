function g( q )
   q := q + 1
   return
function f( p )
   g( @p )
   p := p * 10
   return
function main()
   local x := 1
   f( @x )
   ? x
   return

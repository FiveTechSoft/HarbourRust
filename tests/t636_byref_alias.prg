function f( a, b )
   a := a + 1
   b := b + 2
   return
function main()
   local x := 5
   f( @x, @x )
   ? x
   return

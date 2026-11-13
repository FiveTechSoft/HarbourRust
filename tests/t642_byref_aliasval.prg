function f( a, b )
   a := a + b
   return
function main()
   local x := 5
   f( @x, x )
   ? x
   return

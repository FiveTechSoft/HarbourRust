function f( p )
   for i := 1 to 10
      p := p + "!"
   next
   return
function main()
   local s := "abc"
   f( @s )
   ? s
   ? hb_memcheck()
   return

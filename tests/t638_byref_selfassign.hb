function f( p )
   p := p
   p := p + "!"
   return
function main()
   local s := "abc"
   f( @s )
   ? s
   ? hb_memcheck()
   return

function f( p )
   return p + "?"
function main()
   local s := "abc"
   ? f( @s )
   ? s
   ? hb_memcheck()
   return

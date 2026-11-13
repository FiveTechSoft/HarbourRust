function sadd( p )
   p := p + "!"
   return
function main()
   local s := "abc"
   sadd( @s )
   ? s
   sadd( @s )
   ? s
   return

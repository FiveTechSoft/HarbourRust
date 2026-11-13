function excl( s )
   s := s + "!"
   return s
function wrap( p, q )
   p := p + excl( @q )
   return
function main()
   local a := "x"
   local b := "y"
   wrap( @a, @b )
   ? a
   ? b
   return

function bumpret( n )
   n := n + 10
   return n
function apply( p, q )
   p := p + bumpret( @q )
   return
function main()
   local a := 1
   local b := 2
   apply( @a, @b )
   ? a
   ? b
   return

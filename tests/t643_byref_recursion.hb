function countdown( n )
   if n > 0
      n := n - 1
      countdown( @n )
   endif
   return
function main()
   local x := 3
   countdown( @x )
   ? x
   return

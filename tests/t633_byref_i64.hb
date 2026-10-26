function inc( p )
   p := p + 1
   return
function main()
   local x := 1
   inc( @x )
   ? x
   inc( @x )
   ? x
   return

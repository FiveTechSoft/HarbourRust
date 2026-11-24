// main's return value is discarded; a returned call still runs first.
function main()
   local n := 2
   ? "start|"
   if n == 1
      return "one"
   endif
   if n == 2
      return (Shout("two"), Shout("three"), 2)
   endif
   ? "never|"
return(7)

function Shout(c)
   ? "shout", c + "|"
return Len(c)

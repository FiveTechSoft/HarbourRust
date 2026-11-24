// main may return any value; Harbour ignores it and exits with code 0.
function main()
   local i
   for i := 1 to 3
      ? "i", Str(i, 1) + "|"
      if i == 2
         return(i)
      endif
   next
   ? "never|"
return 0

function MakeF()
   local d
   d := 1.5
   return d
function main()
   local i
   for i := 1 to 500
      begin sequence
         break(MakeF())
      recover
      end sequence
   next
   ? "done"
return nil

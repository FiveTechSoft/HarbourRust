function Make()
   local d
   d := "send-str"
   return d
function main()
   local i
   for i := 1 to 500
      begin sequence
         break(Make())
      recover
      end sequence
   next
   ? "done"
return nil

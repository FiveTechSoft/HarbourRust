function Make()
   local d
   d := "long-string"
   return d
function main()
   local i
   for i := 1 to 500
      try
         break(Make())
      catch
      end
   next
   ? "done"
return nil

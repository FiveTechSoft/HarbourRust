function makef()
   local f
   f := 0.0001
return f
function main()
   local i
   for i := 1 to 500
      hb_idleSleep(makef())
   next
   ? "done"
return nil

function makes()
   local s
   s := "owned-buffer"
return s
function main()
   local i
   for i := 1 to 500
      hb_idleSleep(makes())
   next
   ? "done"
return nil

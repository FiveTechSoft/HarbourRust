function makev()
   local d
   d := "owned-buffer"
return d
function main()
   local i, z, d, o
   for i := 1 to 500
      try
         z := makev() / 2
      catch
      end
   next
   ? "done"
return nil

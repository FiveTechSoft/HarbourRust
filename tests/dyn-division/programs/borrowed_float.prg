function makev()
   local d
   d := 7.5
return d
function main()
   local i, z, d, o
   d := 7.5
   for i := 1 to 500
      try
         z := d / 2
      catch
      end
   next
   ? "done"
return nil

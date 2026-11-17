CREATE CLASS T
   DATA d
ENDCLASS
function main()
   local o, i, z
   o := T()
   o:d := {1,2,3}
   for i := 1 to 500
      try
         z := o:d / 2
      catch
      end
   next
   ? "done"
return nil

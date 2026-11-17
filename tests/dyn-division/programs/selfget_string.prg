CREATE CLASS T
   DATA d
   METHOD V()
   METHOD Calc()
ENDCLASS
METHOD V() CLASS T
   local d
   d := "owned-buffer"
return d
METHOD Calc() CLASS T
   local x
   try
      x := ::d / 2
   catch
   end
return 1.0
function makev()
   local d
   d := "owned-buffer"
return d
function main()
   local i, z, d, o
   o := T()
   o:d := "owned-buffer"
   for i := 1 to 500
      try
         z := o:Calc()
      catch
      end
   next
   ? "done"
return nil

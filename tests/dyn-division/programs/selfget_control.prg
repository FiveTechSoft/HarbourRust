CREATE CLASS T
   DATA d
   METHOD V()
   METHOD Calc()
ENDCLASS
METHOD V() CLASS T
   local d
   d := 7.5
return d
METHOD Calc() CLASS T
   local x
   try
      x := 7.5 / 2
   catch
   end
return 1.0
function makev()
   local d
   d := 7.5
return d
function main()
   local i, z, d, o
   o := T()
   o:d := 7.5
   for i := 1 to 500
      try
         z := o:Calc()
      catch
      end
   next
   ? "done"
return nil

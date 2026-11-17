function lhs()
   local d
   ? "lhs"
   d := "owned"
return d
function rhs()
   local d
   ? "rhs"
   d := 2
return d
function main()
   local e, z
   try
      z := lhs() / rhs()
   catch e
      ? e
   end
return nil

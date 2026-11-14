function main()
   local e
   try
      ? "outer try"
      helper()
   catch e
      ? "outer caught:", e
   finally
      ? "outer finally"
   end
   ? "after end"
return nil
function helper()
   try
      ? "inner try"
      throwit(5)
      ? "inner unreached"
   finally
      ? "inner finally"
   end
return nil
function throwit(i)
   local a := {1}
   ? a[i]
return nil

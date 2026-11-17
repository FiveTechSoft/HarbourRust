function main()
   local e
   begin sequence
      ? "outer try"
      helper()
   recover using e
      ? "outer caught:", e:description
   always
      ? "outer finally"
   end sequence
   ? "after end"
return nil
function helper()
   begin sequence
      ? "inner try"
      throwit(5)
      ? "inner unreached"
   always
      ? "inner finally"
   end sequence
return nil
function throwit(i)
   local oE := ErrorNew()
   oE:description := "Bound error: array access"
   Break(oE)
return nil

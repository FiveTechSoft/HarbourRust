function main()
   local oErr
   local oE := ErrorNew()
   oE:description := "Bound error: array access"
   begin sequence
      ? "in try"
      Break(oE)
      ? "after error"
   recover using oErr
      ? "caught:", oErr:description
   always
      ? "in finally"
   end sequence
   ? "after end"
return nil

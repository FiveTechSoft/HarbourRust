function main()
   local oErr
   begin sequence
      ? "in try"
   recover using oErr
      ? "caught:", oErr
   always
      ? "in finally"
   end sequence
   ? "after end"
return nil
